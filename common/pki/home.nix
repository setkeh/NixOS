# The Atlas root in the user's NSS database (~/.pki/nssdb), for Chromium-based browsers
# (Vivaldi, Chromium), which ignore /etc/ssl and read only this database. The system side is
# ./default.nix.
#
# The entry is deleted and re-added on every activation, so the trust flags always match
# this file, even if they were edited by hand.
{ pkgs, lib, ... }:
let
  certutil = "${pkgs.nssTools}/bin/certutil";
in {
  home.activation.atlasRootNssdb = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    nssdir="$HOME/.pki/nssdb"
    run mkdir -p "$nssdir"
    if [ ! -f "$nssdir/cert9.db" ]; then
      run ${certutil} -d "sql:$nssdir" -N --empty-password
    fi
    ${certutil} -d "sql:$nssdir" -D -n atlas-root 2>/dev/null || true
    run ${certutil} -d "sql:$nssdir" -A -t "C,," -n atlas-root -i ${./atlas-root.crt}
  '';
}
