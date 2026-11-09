# ComfyUI as a desktop app.
#
# `pkgs.comfyui-rocm` (etc/overlays/comfyui.nix) provides the `comfy-ui` server.
# This module makes it behave like an application:
#   - a user service `comfyui` runs the server on demand (not started at login)
#   - a launcher entry starts that service and opens the UI in the browser
#   - `comfyui-desktop` / `comfyui-desktop stop` do the same from a shell
# Models, outputs, custom nodes and the Manager's venv all live under dataDir.
{ config, pkgs, lib, ... }:
let
  dataDir = "${config.home.homeDirectory}/ComfyUI";
  port = 8188;
  url = "http://127.0.0.1:${toString port}";

  launcher = pkgs.writeShellApplication {
    name = "comfyui-desktop";
    runtimeInputs = [ pkgs.systemd pkgs.xdg-utils pkgs.curl ];
    text = ''
      if [ "''${1:-}" = "stop" ]; then
        systemctl --user stop comfyui.service
        exit 0
      fi
      systemctl --user start comfyui.service
      # Wait for the server before opening the browser (first start loads torch).
      for _ in $(seq 1 120); do
        if curl -fsS -o /dev/null "${url}/system_stats"; then break; fi
        sleep 1
      done
      xdg-open "${url}"
    '';
  };

  # Custom nodes beyond the ones comfyui-rocm bundles (Impact Pack, KJNodes, ...), pinned here and
  # symlinked into custom_nodes/ at service start. Their Python deps are already in comfyui-rocm's
  # environment. The name is the directory under custom_nodes/.
  customNodes = {
    "ComfyUI-Impact-Subpack" = pkgs.fetchFromGitHub {
      owner = "ltdrdata";
      repo = "ComfyUI-Impact-Subpack";
      rev = "50c7b71a6a224734cc9b21963c6d1926816a97f1";
      hash = "sha256-+qYmGdHjrWYfJ+uqGURWk1y8kVR0pBc+ObjUyM0A7UA=";
    };
    "comfyui_ipadapter_plus" = pkgs.fetchFromGitHub {
      owner = "cubiq";
      repo = "ComfyUI_IPAdapter_plus";
      rev = "f904b4c3c3adbda990f32b90eb52e1924467c9ef";
      hash = "sha256-u3/8CLeJx1QrHPkvqCc6g87SlCR7zRCwnlux/Uz5Grw=";
    };
    # Only DWPreprocessor and DepthAnythingV2Preprocessor are needed; the preprocessors that want
    # mediapipe, trimesh etc. fail to import and are skipped.
    "comfyui_controlnet_aux" = pkgs.fetchFromGitHub {
      owner = "Fannovel16";
      repo = "comfyui_controlnet_aux";
      rev = "a587a4c1594524c1d2de5cd1a86cd868ff448e1c";
      hash = "sha256-sIagHbtP1W+bF63AlaqZZ/Gtc0yqc67ur64h8BWxdc4=";
    };
  };

  # Links the declared nodes and drops links to nodes no longer declared (tracked in a state file,
  # so the bundled links comfyui-rocm makes are never touched). A real directory in the way is left
  # alone and reported, never deleted.
  linkCustomNodes = pkgs.writeShellScript "comfyui-link-custom-nodes" ''
    set -eu
    nodes="${dataDir}/custom_nodes"
    state="$nodes/.comfy-declared"
    mkdir -p "$nodes"
    if [ -f "$state" ]; then
      while IFS='=' read -r name target; do
        if [ -L "$nodes/$name" ] && [ "$(readlink "$nodes/$name")" = "$target" ]; then
          rm -f "$nodes/$name"
        fi
      done < "$state"
    fi
    : > "$state"
    ${lib.concatStrings (lib.mapAttrsToList (name: src: ''
      if [ -e "$nodes/${name}" ] && [ ! -L "$nodes/${name}" ]; then
        echo "comfyui: $nodes/${name} is a real directory, not linking the declared ${name}" >&2
      else
        ln -sfn ${src} "$nodes/${name}"
        echo "${name}=${src}" >> "$state"
      fi
    '') customNodes)}
  '';
in {
  # bitsandbytes shells out to rocminfo for the GPU arch and warp size; the service gets it from the
  # user profile, which is on the systemd user PATH.
  home.packages = [ pkgs.comfyui-rocm launcher pkgs.rocmPackages.rocminfo ];

  systemd.user.services.comfyui = {
    Unit = {
      Description = "ComfyUI server (ROCm)";
    };
    Service = {
      # controlnet_aux downloads its preprocessor checkpoints into its own folder (the store) by default.
      Environment = [ "AUX_ANNOTATOR_CKPTS_PATH=%h/ComfyUI/models/controlnet_aux_ckpts" ];
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p %h/ComfyUI/models/controlnet_aux_ckpts"
        "${linkCustomNodes}"
      ];
      ExecStart = "${lib.getExe pkgs.comfyui-rocm} --base-directory ${dataDir} --port ${toString port} --enable-manager --use-pytorch-cross-attention --disable-pinned-memory";
      Nice = 10;
      Restart = "on-failure";
      StandardOutput = "append:%h/ComfyUI/comfyui.log";
      StandardError = "append:%h/ComfyUI/comfyui.log";
    };
    # No Install section: started by the launcher, never at login.
  };

  xdg.desktopEntries.comfyui-desktop = {
    name = "ComfyUI";
    comment = "Start ComfyUI and open it in the browser";
    exec = "${lib.getExe launcher}";
    terminal = false;
    categories = [ "Graphics" "Science" ];
  };
}
