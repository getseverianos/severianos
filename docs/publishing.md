# Publishing SeverianOS

Everything so far works locally. To make SeverianOS public:

## 1. Source code

```sh
cd ~/severian/src
git init && git add . && git commit -m "SeverianOS 0.1.0"
```

Create the GitHub organisation/repository and push. `build/` and ISOs stay out
of git (`.gitignore`).

## 2. A signing key

Users must be able to trust packages and ISOs.

```sh
gpg --full-generate-key            # ed25519, "SeverianOS Build Key"
gpg --list-secret-keys --keyid-format long
```

Put the key ID into `GPG_KEY` in `config.sh`. `build.sh` then signs every
package, the repo database and the ISO. Keep a backup of the key offline.

Next step after that (not done yet): a `severian-keyring` package that ships
the public key, so installed systems can use `SigLevel = Required`.

## 3. The package repo

Upload the contents of `build/repo/` (`*.pkg.tar.zst`, `*.sig`, `severian.db*`,
`severian.files*`) to a GitHub release, e.g. tag `x86_64`. Then set:

```sh
REPO_URL="https://github.com/<org>/<repo>/releases/download/x86_64"
```

Rebuild. From now on `sevinstall` adds `[severian]` to installed systems, and
`sevupdate` delivers new SeverianOS packages like any other update.

Do **not** set `REPO_URL` before the URL works: pacman refuses to update when
a configured repo is unreachable.

## 4. A release

1. Raise versions in the changed PKGBUILDs, update `CHANGELOG.md`.
2. `./build.sh all`
3. Test: `scripts/vm.sh install` (UEFI and BIOS), then real hardware.
4. Upload ISO + `.sha256` + `.b2` (+ `.sig`) to a GitHub release.

## Arch Linux trademark

SeverianOS is *based on* Arch Linux and says so. It must not be called
"Arch", use the Arch logo, or suggest endorsement. Support requests belong to
us, not to Arch's forums or bug tracker.
