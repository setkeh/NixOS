# Trust the internal Atlas root CA (step-ca) system-wide.
#
# step-ca issues the certificates for internal names such as the git ingress, so
# anything that talks to them has to trust this root. atlas-root.crt is the public
# certificate from Saltstack's pillar/common/stepca.sls (stepca:root_ca_crt), the same file
# salt/common/trust.sls installs on the minions. It isn't secret.
#
# security.pki adds it to /etc/ssl/certs/ca-certificates.crt, which curl, git, Go, nix
# and Python (nixpkgs patches certifi) read. Firefox keeps its own NSS store, so it gets
# the root through policy. Chromium-based browsers read ~/.pki/nssdb and don't see either.
{ config, lib, ... }:
{
  security.pki.certificateFiles = [ ./atlas-root.crt ];

  programs.firefox.policies = lib.mkIf config.programs.firefox.enable {
    Certificates.Install = [ "${./atlas-root.crt}" ];
  };
}
