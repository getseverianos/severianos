#!/usr/bin/env bash
# SeverianOS build
#
#   ./build.sh check      verify that every dependency exists in the Arch repos
#   ./build.sh packages   build all packages in packages/ (as your user)
#   ./build.sh repo       create the local [severian] repo from the built packages
#   ./build.sh iso        build the ISO with that repo (asks for sudo)
#   ./build.sh all        check + packages + repo + iso
#   ./build.sh clean      remove build/
#
# Settings: config.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=config.sh
. "$ROOT/config.sh"
BUILD=$ROOT/build
REPO=$BUILD/repo
PROFILE=$BUILD/profile
WORK=$BUILD/work
OUT=${OUT_DIR:-$ROOT/out}

E=$'\e[38;2;181;82;59m'; G=$'\e[38;2;127;154;101m'; M=$'\e[38;2;111;106;98m'; R=$'\e[0m'
step() { printf '\n%s●%s %s\n' "$E" "$R" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$R" "$*"; }
note() { printf '  %s%s%s\n' "$M" "$*" "$R"; }
die()  { printf '  %s✗ %s%s\n' "$E" "$*" "$R" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "run build.sh as your normal user (it calls sudo itself)"

pkgdirs() { find "$ROOT/packages" -mindepth 2 -maxdepth 2 -name PKGBUILD -printf '%h\n' | sort; }

check() {
    step "Checking dependencies"
    for tool in makepkg repo-add fakeroot mkarchiso; do
        command -v "$tool" >/dev/null || die "$tool missing – sudo pacman -S --needed base-devel archiso"
    done
    local deps=() d missing=0
    for d in $(pkgdirs); do
        # shellcheck disable=SC1091
        mapfile -t -O "${#deps[@]}" deps < <(cd "$d" && depends=() && . ./PKGBUILD && printf '%s\n' "${depends[@]}")
    done
    mapfile -t -O "${#deps[@]}" deps < <(grep -v '^\s*#' "$ROOT/iso/packages.x86_64" | grep -v '^\s*$')
    for d in $(printf '%s\n' "${deps[@]}" | sed 's/[<>=].*//' | sort -u); do
        [[ $d == severian-* ]] && continue
        pacman -Si "$d" >/dev/null 2>&1 || { printf '  %s✗ not in the repos: %s%s\n' "$E" "$d" "$R"; missing=1; }
    done
    (( missing == 0 )) || die "fix the package names above"
    ok "all dependencies available"
}

packages() {
    step "Building packages"
    mkdir -p "$REPO" "$BUILD/makepkg"
    local sign=() d
    [[ -n $GPG_KEY ]] && sign=(--sign --key "$GPG_KEY")
    export SEVERIAN_REPO_URL=$REPO_URL
    for d in $(pkgdirs); do
        ( cd "$d" && PKGDEST=$REPO BUILDDIR=$BUILD/makepkg PKGEXT=.pkg.tar.zst \
            makepkg --force --clean --cleanbuild --nodeps --noconfirm "${sign[@]}" >/dev/null ) \
            || die "makepkg failed in ${d##*/} – run it there by hand to see why"
        ok "${d##*/}"
    done
}

repo() {
    step "Creating the [severian] repo"
    [[ -d $REPO ]] || die "no packages built yet – ./build.sh packages"
    local d name files
    # keep only the newest file of each package
    for d in $(pkgdirs); do
        name=${d##*/}
        mapfile -t files < <(find "$REPO" -maxdepth 1 -name "$name-[0-9]*.pkg.tar.zst" -printf '%f\n' | sort -V)
        (( ${#files[@]} > 1 )) && for f in "${files[@]:0:${#files[@]}-1}"; do rm -f "$REPO/$f" "$REPO/$f.sig"; done
    done
    rm -f "$REPO"/severian.{db,files}*
    local sign=(); [[ -n $GPG_KEY ]] && sign=(--sign --key "$GPG_KEY")
    repo-add -q "${sign[@]}" "$REPO/severian.db.tar.zst" "$REPO"/*.pkg.tar.zst
    ok "$(find "$REPO" -name '*.pkg.tar.zst' | wc -l) packages in $REPO"
}

iso() {
    step "Preparing the ISO profile"
    [[ -f $REPO/severian.db.tar.zst ]] || die "no repo yet – ./build.sh repo"
    rm -rf "$PROFILE"
    cp -a "$ROOT/iso" "$PROFILE"
    # Live system: the repo is copied onto the medium so sevinstall can install from it
    install -d "$PROFILE/airootfs/opt/severian/repo"
    cp -a "$REPO"/. "$PROFILE/airootfs/opt/severian/repo/"
    cp "$ROOT/iso/pacman.conf" "$PROFILE/airootfs/etc/pacman.conf"
    printf '\n[severian]\nSigLevel = Optional TrustAll\nServer = file:///opt/severian/repo\n' >> "$PROFILE/airootfs/etc/pacman.conf"
    # Build time: mkarchiso installs from the repo on this machine
    printf '\n[severian]\nSigLevel = Optional TrustAll\nServer = file://%s\n' "$REPO" >> "$PROFILE/pacman.conf"
    ok "profile in $PROFILE"

    step "Building the ISO (sudo)"
    sudo rm -rf "$WORK"
    mkdir -p "$OUT"
    local st
    set +e
    sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE" 2>&1 | tee "$BUILD/iso.log" \
        | grep --line-buffered -E '^\[mkarchiso\] (INFO: (Installing|Creating)|ERROR|WARNING)'
    st=${PIPESTATUS[0]}
    set -e
    (( st == 0 )) || die "mkarchiso failed – see $BUILD/iso.log"
    sudo chown -R "$(id -u):$(id -g)" "$OUT"

    local iso; iso=$(find "$OUT" -maxdepth 1 -name 'severianos-*.iso' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
    ( cd "$OUT" && sha256sum "${iso##*/}" > "${iso##*/}.sha256" && b2sum "${iso##*/}" > "${iso##*/}.b2" )
    [[ -n $GPG_KEY ]] && gpg --batch --yes --local-user "$GPG_KEY" --detach-sign "$iso"
    ok "${iso##*/}  ($(du -h "$iso" | cut -f1))"
    note "test it: scripts/vm.sh live   ·   install test: scripts/vm.sh install"
}

case ${1:-all} in
    check)    check ;;
    packages) packages ;;
    repo)     repo ;;
    iso)      iso ;;
    all)      check; packages; repo; iso ;;
    clean)    sudo rm -rf "$BUILD"; ok "build/ removed" ;;
    *)        sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
