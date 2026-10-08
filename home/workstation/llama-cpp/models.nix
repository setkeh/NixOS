{ config, pkgs, lib, ... }:
let
  # Every model llama-server can load, described once. The deployed models
  # directory and models.ini are both generated from this attrset, so the paths
  # llama-server reads can never drift from the files that were actually pinned.
  #
  # Hashes are the SHA-256 Hugging Face publishes for each LFS file (the `oid`
  # from the paths-info API), converted to SRI with:
  #   nix hash convert --hash-algo sha256 --to sri <hex>
  # The URL is pinned to a repo commit rather than `main` so the URL itself is
  # stable; the hash is what guarantees the bytes.
  models = {
    "qwen3.8-flash" = {
      repo = "unsloth/Qwen3.8-Flash-Next-GGUF";
      revision = "38bb39ee97821de2c9009abb7e93950eec396e66";
      dir = "UD-IQ3_XXS";
      shards = [
        {
          file = "Qwen3.8-Flash-Next-UD-IQ3_XXS-00001-of-00003.gguf";
          hash = "sha256-Jo+B/e3zFJpTjyUjCJJ6TV0fbgYsF4VopR47UZdE+Kg=";
        }
        {
          file = "Qwen3.8-Flash-Next-UD-IQ3_XXS-00002-of-00003.gguf";
          hash = "sha256-z+YAsja4jH+tFhOlyl6DufK+tjy9RMMrK+UKRHR8aV8=";
        }
        {
          file = "Qwen3.8-Flash-Next-UD-IQ3_XXS-00003-of-00003.gguf";
          hash = "sha256-8ZEro0x5Qn0ilaWNyytzK1kxr1vvejc8YFV6V9nuclA=";
        }
      ];
      # Vision projector (mtmd). Lives at the repo root, not in `dir`. Omit for
      # text-only models. Offloaded to the GPU by default; set
      # `no-mmproj-offload = true` in settings to keep it on the CPU.
      mmproj = {
        file = "mmproj-F16.gguf";
        hash = "sha256-H3t/C5hM8GXGBDYMKcgJg2LtYbKQ2w/xLG82C7GoqYA=";
      };
      # Per-model llama-server settings, written verbatim into this model's
      # ini section. Anything llama-server accepts as a long option works here.
      settings = {
        ctx-size = 128000;
        n-gpu-layers = 99;
        n-cpu-moe = 36;
        flash-attn = true;
        # Host-RAM cap for the prompt cache. It competes with the page cache that
        # holds the experts, so keep it modest on a 62 GB box.
        cache-ram = 6144;
        # q8_0 KV cache halves the per-token KV cost; needs flash-attn (on).
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        # No ubatch-size above the default: 2048 grew the compute buffer at runtime until the
        # GPU ran out of memory for command submission and niri crashed (Aegis-AIOS #140). The
        # model still loads fine at 2048; the failure only shows on the first large prefill.
        load-mode = "auto";
      };
    };

    # The everyday tier: voice, home automation, coding, review and the librarian. A dense 27B
    # small enough to live entirely in VRAM, so none of its weights are paged from disk or read
    # from system RAM. Hybrid attention: only 16 of its 64 layers keep a KV cache, so a 128k
    # context costs ~4.2 GiB at q8 (Aegis-AIOS #140).
    "qwen3.8-27b" = {
      repo = "unsloth/Qwen3.8-27B-GGUF";
      revision = "4ca720788d1e01f1bff70c033e0d0028fd02e502";
      # No `dir`: this repo keeps its GGUFs at the root.
      shards = [
        {
          file = "Qwen3.8-27B-UD-Q4_K_M.gguf";
          hash = "sha256-Mi4ZT/eXQce6pJfCQPZ39UsgGw76tEyo5Q8SKzkSNII=";
        }
      ];
      mmproj = {
        file = "mmproj-F16.gguf";
        hash = "sha256-y7hBqe4GNrLsFy9buN8uqN/rAekP58YSZYHWYqC05D4=";
      };
      settings = {
        # Hermes will not start below 64k.
        ctx-size = 128000;
        n-gpu-layers = 99;
        flash-attn = true;
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        # The projector stays on the CPU: 0.88 GiB of VRAM is the margin that keeps niri
        # alive, and voice never sends images. Image turns still work, just slower.
        no-mmproj-offload = true;
        load-mode = "auto";
        cache-ram = 16384;
        log-verbosity = 4;
      };
    };
  };

  # Settings applied to every model via the `[*]` section.
  globalSettings = {
    ctx-size = 4096;
    n-gpu-layers = 99;
  };

  modelsDir = "${config.xdg.configHome}/llama-cpp/models";

  fetchFile = model: relPath: hash:
    pkgs.fetchurl {
      url = "https://huggingface.co/${model.repo}/resolve/${model.revision}/${relPath}";
      inherit hash;
    };

  # Where a shard lives in its repo. `dir` is optional: some repos keep every quant in a
  # subdirectory, others keep the GGUFs at the root.
  shardPath = model: shard:
    if model ? dir then "${model.dir}/${shard.file}" else shard.file;

  # The projector is linked under a per-model name so two models shipping a
  # file called mmproj-F16.gguf cannot collide in the shared directory.
  mmprojName = name: "${name}.mmproj.gguf";

  # One directory containing every shard of every model, as symlinks into the
  # store. llama.cpp finds split files by rewriting the -0000N-of-0000M suffix
  # of the first shard's path, so all shards must sit side by side.
  modelsFarm = pkgs.linkFarm "llama-cpp-models" (lib.concatLists (lib.mapAttrsToList
    (name: model:
      map (shard: {
        name = shard.file;
        path = fetchFile model (shardPath model shard) shard.hash;
      }) model.shards
      ++ lib.optional (model ? mmproj) {
        name = mmprojName name;
        path = fetchFile model model.mmproj.file model.mmproj.hash;
      })
    models));

  # llama-server is pointed at the first shard; it loads the rest itself.
  modelSection = name: model: {
    model = "${modelsDir}/${(builtins.head model.shards).file}";
  } // lib.optionalAttrs (model ? mmproj) {
    mmproj = "${modelsDir}/${mmprojName name}";
  } // model.settings;

  modelsIni = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  } ({ "*" = globalSettings; } // lib.mapAttrs modelSection models);

in {
  xdg.configFile."llama-cpp/models".source = modelsFarm;
  xdg.configFile."llama-cpp/models.ini".text = modelsIni;
}
