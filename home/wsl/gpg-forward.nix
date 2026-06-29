{ config, pkgs, ... }:

let
  gpgTunnel = pkgs.writeShellScriptBin "gpg-tunnel" ''
    REMOTE_USER="setkeh"
    REMOTE_HOST="10.0.66.75"
    REMOTE_SOCKET="/run/user/1000/gnupg/S.gpg-agent"
    LOCAL_SOCKET=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-extra-socket)

    cleanup() {
        echo ""
        echo "Closing tunnel and releasing remote socket..."
        ${pkgs.openssh}/bin/ssh "${REMOTE_USER}@${REMOTE_HOST}" "rm -f ${REMOTE_SOCKET}" 2>/dev/null || true
        echo "Done. Laptop can now take over."
        exit 0
    }

    trap cleanup INT TERM EXIT

    echo "GPG tunnel → ${REMOTE_HOST}"
    echo "Local:  ${LOCAL_SOCKET}"
    echo "Remote: ${REMOTE_SOCKET}"
    echo "Press Ctrl+C to release the socket for another machine."
    echo ""

    ${pkgs.openssh}/bin/ssh \
        -N \
        -o "ExitOnForwardFailure=yes" \
        -o "ServerAliveInterval=30" \
        -o "ServerAliveCountMax=3" \
        -o "StreamLocalBindUnlink=yes" \
        -R "${REMOTE_SOCKET}:''${LOCAL_SOCKET}" \
        "${REMOTE_USER}@${REMOTE_HOST}"
  '';
in
{
  environment.systemPackages = [ gpgTunnel ];
}