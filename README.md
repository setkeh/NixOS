# NixOS
NixOS Configuration and Dotfiles Repo

## Flake

I'm still relativly newish to flakes so i have likely done some things incorrectly, But at this stake its working on my laptop and hopefully soon a lot more hosts.

That said please open an issue/pr if you have any suggestions on fixing anything i had implimented oddly.

## Secrets

Currently im using [Sops](https://github.com/mic92/sops-nix) for secret management, i Tried agenix but just couldent reliably get secrets to decrypt using my Yubikeys though Sops GPG keys solves the issue.

I am using GPG for my user keys as all my Yubikeys have the same GPG key on them and are used to back each other up if one fails, For Hosts im using ssh keys using the Sops `ssh-to-age` tool.

E.g

```
$ nix-shell -p ssh-to-age --run 'ssh-keyscan example.com | ssh-to-age'
age1rgffpespcyjn0d8jglk7km9kfrfhdyev6camd3rck6pn8y47ze4sug23v3
$ nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
age1rgffpespcyjn0d8jglk7km9kfrfhdyev6camd3rck6pn8y47ze4sug23v3
```