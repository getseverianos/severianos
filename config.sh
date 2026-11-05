# SeverianOS build configuration – sourced by build.sh and scripts/vm.sh

# Where finished ISOs go, and where the test VM lives
OUT_DIR="$HOME/severian/out"
VM_DIR="$HOME/severian/vm"

# GPG key (ID or fingerprint) to sign packages, the repo and the ISO.
# Empty = unsigned, which is fine for local testing. See docs/publishing.md.
GPG_KEY=""

# Public URL of the [severian] package repo. Empty = not published yet:
# installed systems then get SeverianOS updates only by reinstalling.
# Example: https://github.com/getseverianos/repo/releases/download/x86_64
REPO_URL=""
