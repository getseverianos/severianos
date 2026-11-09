# Security

## Reporting a vulnerability

Please **do not open a public issue** for security problems. Use GitHub's
private reporting instead: *Security → Report a vulnerability* in
github.com/getseverianos/severianos.

Tell us what is affected, how to reproduce it and what an attacker could do.
We will answer as soon as we can and credit you in the fix unless you prefer
otherwise.

Vulnerabilities in Arch Linux packages (kernel, Firefox, …) belong to the Arch
Linux security team or the upstream project; tell us too if SeverianOS makes
them worse.

## Signing key

Every SeverianOS package, the repository database and every ISO are signed
with:

```
SeverianOS Build Key
ed25519, created 2026-11-05, expires 2028-11-04
614E 5176 E325 7EA9 2972  F3D4 1CC2 187B 6745 B29E
```

The public key ships in the `severian-keyring` package and in the repository
(`packages/severian-keyring/files/usr/share/pacman/keyrings/severian.gpg`).

Verify an ISO:

```sh
gpg --import severian.gpg
gpg --verify severianos-0.1.0-x86_64.iso.sig severianos-0.1.0-x86_64.iso
sha256sum -c severianos-0.1.0-x86_64.iso.sha256
```

Installed systems only accept SeverianOS packages signed with this key
(`SigLevel = Required`). If the key is ever compromised, it will be revoked
through an update of `severian-keyring` and announced here.
