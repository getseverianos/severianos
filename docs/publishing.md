# Publishing SeverianOS

## Where things live

| what                    | where                                               | visibility |
|-------------------------|-----------------------------------------------------|------------|
| source code             | github.com/getseverianos/severianos                 | private until 0.1 |
| package repo (binaries) | github.com/getseverianos/packages, release `x86_64` | public     |
| ISO releases            | github.com/getseverianos/severianos/releases        | with 0.1   |

The package repo has to be public from the start: pacman cannot download
release files from a private repository.

## The signing key

SeverianOS is signed with

    614E5176E3257EA92972F3D41CC2187B6745B29E   SeverianOS Build Key (ed25519, expires 2028-11-04)

- `GPG_KEY` in `config.sh` holds this fingerprint; `build.sh` then signs every
  package, the repo database and the ISO.
- The public key ships in `severian-keyring`
  (`packages/severian-keyring/files/usr/share/pacman/keyrings/`): `severian.gpg`,
  `severian-trusted` (fingerprint), `severian-revoked`.
- Installing or upgrading `severian-keyring` runs `pacman-key --populate severian`.
- Installed systems use `SigLevel = Required` for `[severian]`: unsigned or
  foreign-signed packages are refused.

**Backups:** the secret key (`gpg --export-secret-keys --armor`) and the
revocation certificate (`~/.gnupg/openpgp-revocs.d/<fingerprint>.rev`) live
offline on a USB stick. Never in git, never in a chat.

**Expiry:** extend before 2028-11-04 with `gpg --quick-set-expire <fpr> 2y`,
then rebuild and publish `severian-keyring` with the refreshed `severian.gpg`.

**If the key is ever compromised:** import the revocation certificate, move the
fingerprint into `severian-revoked`, create a new key, ship both in a new
`severian-keyring`.

## Publishing packages

```sh
./build.sh packages && ./build.sh repo     # build and sign
./build.sh publish                         # upload to getseverianos/packages
```

`publish` uploads the packages, their signatures and `severian.db` / `.files`
(as real files – GitHub release assets cannot be symlinks), and deletes assets
of package versions that are no longer in the repo.

Installed systems pick up new packages with `sevupdate` (or `pacman -Syu`).
Only packages whose version went up are updated – always raise `pkgrel`.

## Enabling updates on installed systems

Once the first `publish` worked, set in `config.sh`:

```sh
REPO_URL="https://github.com/getseverianos/packages/releases/download/x86_64"
```

and rebuild (`./build.sh all`). Systems installed from that ISO get
`[severian]` in `/etc/pacman.conf`. Never set `REPO_URL` before the URL works:
pacman refuses to update when a configured repo is unreachable.

## A release

1. Raise versions in the changed PKGBUILDs, update `CHANGELOG.md`.
2. `./build.sh all && ./build.sh publish`
3. Test: `scripts/vm.sh install` (UEFI and BIOS), then real hardware.
4. `git tag v0.x.y && git push --tags`
5. Create a GitHub release in `getseverianos/severianos` with the ISO,
   `.sha256`, `.b2` and `.sig`.

## Arch Linux trademark

SeverianOS is *based on* Arch Linux and says so. It must not be called
"Arch", use the Arch logo, or suggest endorsement. Support requests belong to
us, not to Arch's forums or bug tracker.
