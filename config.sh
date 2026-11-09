# SeverianOS build configuration – sourced by build.sh and scripts/vm.sh

# Where finished ISOs go, and where the test VM lives
OUT_DIR="$HOME/severian/out"
VM_DIR="$HOME/severian/vm"

# GPG key (full fingerprint) that signs packages, the repo and the ISO.
# Empty = unsigned, fine for local experiments. See docs/publishing.md.
GPG_KEY="614E5176E3257EA92972F3D41CC2187B6745B29E"

# Where ./build.sh publish uploads the package repo: a PUBLIC GitHub
# repository and the release tag that holds the files.
PUBLISH_REPO="getseverianos/packages"
PUBLISH_TAG="x86_64"

# Public URL of the [severian] repo, written into installed systems.
# Leave empty until ./build.sh publish has run once and the URL works:
# pacman refuses to update when a configured repo is unreachable.
REPO_URL=""
