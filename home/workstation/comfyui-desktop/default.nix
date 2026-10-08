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
in {
  home.packages = [ pkgs.comfyui-rocm launcher ];

  systemd.user.services.comfyui = {
    Unit = {
      Description = "ComfyUI server (ROCm)";
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.comfyui-rocm} --base-directory ${dataDir} --port ${toString port} --enable-manager";
      Restart = "on-failure";
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
