{ config, pkgs, age, ... }:

let
  # Strips Claude Code attribution from the commit message, then hands off to
  # the repository's own commit-msg hook if it has one, so setting
  # core.hooksPath globally doesn't silently disable per-project tooling.
  commitMsgHook = pkgs.writeShellScript "commit-msg" ''
    set -euo pipefail

    msg="$1"

    ${pkgs.gnused}/bin/sed -i \
      -e '/^Co-Authored-By: Claude/d' \
      -e '/Generated with \[Claude Code\]/d' \
      -e '/^Claude-Session:/d' \
      "$msg"

    # collapse any blank lines left dangling at the end
    ${pkgs.gnused}/bin/sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$msg"

    # chain to the repo-local hook, if present and executable.
    # --git-dir rather than --git-path, since --git-path honours
    # core.hooksPath and would point back at this script.
    git_dir="$(${pkgs.git}/bin/git rev-parse --git-dir)"
    local_hook="$git_dir/hooks/commit-msg"
    if [ -x "$local_hook" ]; then
      exec "$local_hook" "$@"
    fi
  '';

  gitHooks = pkgs.runCommand "git-hooks" { } ''
    mkdir -p "$out"
    ln -s ${commitMsgHook} "$out/commit-msg"
  '';
in
{
  programs.git = {
    enable = true;
    settings.user.name = "James <SETKEH> Griffis";
    settings.user.email = "setkeh@gmail.com";
    settings.core.hooksPath = "${gitHooks}";
    signing = {
      signByDefault = true;
      key = "FA929DF32F5BEA3FDBBDA2A86740B732D3507B5E";
    };
  };
}
