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
        ubatch-size = 2048;
        load-mode = "auto";
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
        path = fetchFile model "${model.dir}/${shard.file}" shard.hash;
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
