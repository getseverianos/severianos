#!/usr/bin/env bash
# SeverianOS build
#
#   ./build.sh check      verify that every dependency exists in the Arch repos
#   ./build.sh packages   build all packages in packages/ (as your user)
#   ./build.sh repo       create the local [severian] repo from the built packages
#   ./build.sh iso        build the ISO with that repo (asks for sudo)
#   ./build.sh all        check + packages + repo + iso
#   ./build.sh publish    upload the signed repo to GitHub (PUBLISH_REPO, PUBLISH_TAG)
#   ./build.sh release    tag v$(cat VERSION) and create a DRAFT GitHub release with the ISO
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
VERSION=$(cat "$ROOT/VERSION" 2>/dev/null || echo 0.0.0)

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
    if [[ -n $GPG_KEY ]]; then
        gpg --list-secret-keys "$GPG_KEY" >/dev/null 2>&1 || die "signing key $GPG_KEY not in your GPG keyring"
        local kr=$ROOT/packages/severian-keyring/files/usr/share/pacman/keyrings
        if [[ ! -s $kr/severian.gpg ]]; then
            gpg --export --armor "$GPG_KEY" > "$kr/severian.gpg"
            note "exported the public key to packages/severian-keyring/ – commit it"
        fi
        grep -q "^${GPG_KEY}:" "$kr/severian-trusted" || die "$GPG_KEY is not listed in severian-trusted"
        ok "signing key $GPG_KEY"
    else
        note "GPG_KEY empty – packages and ISO will be unsigned"
    fi
}

packages() {
    step "Building packages"
    mkdir -p "$REPO" "$BUILD/makepkg"
    local sign=() d
    [[ -n $GPG_KEY ]] && sign=(--sign --key "$GPG_KEY")
    export SEVERIAN_REPO_URL=$REPO_URL
    if [[ -n $GPG_KEY ]]; then export SEVERIAN_REPO_SIGLEVEL=Required; else export SEVERIAN_REPO_SIGLEVEL='Optional TrustAll'; fi
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
    if grep -q '^iso_version=' "$PROFILE/profiledef.sh"; then
        sed -i "s/^iso_version=.*/iso_version=\"$VERSION\"/" "$PROFILE/profiledef.sh"
    else
        printf 'iso_version="%s"\n' "$VERSION" >> "$PROFILE/profiledef.sh"
    fi
    # Live system: the repo is copied onto the medium so sevinstall can install from it
    install -d "$PROFILE/airootfs/opt/severian/repo"
    cp -a "$REPO"/. "$PROFILE/airootfs/opt/severian/repo/"
    cp "$ROOT/iso/pacman.conf" "$PROFILE/airootfs/etc/pacman.conf"
    printf '\n[severian]\nSigLevel = Optional TrustAll\nServer = file:///opt/severian/repo\n' >> "$PROFILE/airootfs/etc/pacman.conf"
    # Build time: mkarchiso installs from the repo on this machine
    printf '\n[severian]\nSigLevel = Never\nServer = file://%s\n' "$REPO" >> "$PROFILE/pacman.conf"
    ok "profile in $PROFILE"

    step "Building the ISO (sudo)"
    sudo rm -rf "$WORK"
    sudo rm -f /var/cache/pacman/pkg/severian-*   # stale copies with the same version
    mkdir -p "$OUT"
    local st
    set +e
    sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE" 2>&1 | tee "$BUILD/iso.log" \
        | grep --line-buffered -E '^\[mkarchiso\] (INFO: (Installing|Creating)|ERROR|WARNING)'
    st=${PIPESTATUS[0]}
    set -e
    (( st == 0 )) || die "mkarchiso failed – see $BUILD/iso.log"
    sudo chown -R "$(id -u):$(id -g)" "$OUT"

    local iso=$OUT/severianos-$VERSION-x86_64.iso
    [[ -f $iso ]] || die "expected $iso – check iso_name in iso/profiledef.sh"
    ( cd "$OUT" && sha256sum "${iso##*/}" > "${iso##*/}.sha256" && b2sum "${iso##*/}" > "${iso##*/}.b2" )
    [[ -n $GPG_KEY ]] && gpg --batch --yes --local-user "$GPG_KEY" --detach-sign "$iso"
    ok "${iso##*/}  ($(du -h "$iso" | cut -f1))"
    note "test it: scripts/vm.sh live   ·   install test: scripts/vm.sh install"
}

publish() {
    step "Publishing the repo to github.com/$PUBLISH_REPO (release $PUBLISH_TAG)"
    command -v gh >/dev/null || die "github-cli missing – sudo pacman -S github-cli"
    [[ -n ${PUBLISH_REPO:-} && -n ${PUBLISH_TAG:-} ]] || die "set PUBLISH_REPO and PUBLISH_TAG in config.sh"
    [[ -f $REPO/severian.db.tar.zst ]] || die "no repo yet – ./build.sh packages && ./build.sh repo"
    if [[ -n $GPG_KEY ]]; then
        [[ -f $REPO/severian.db.tar.zst.sig ]] || die "repo is not signed – rebuild with GPG_KEY set"
    else
        note "publishing UNSIGNED packages"
    fi
    gh repo view "$PUBLISH_REPO" >/dev/null 2>&1 || die "github.com/$PUBLISH_REPO does not exist – create it first (public)"

    # GitHub release assets cannot be symlinks, and pacman asks for "severian.db":
    # upload real files under the names pacman expects.
    local stage=$BUILD/publish f
    rm -rf "$stage"; mkdir -p "$stage"
    cp "$REPO"/*.pkg.tar.zst "$stage/"
    if compgen -G "$REPO/*.pkg.tar.zst.sig" >/dev/null; then cp "$REPO"/*.pkg.tar.zst.sig "$stage/"; fi
    cp "$REPO/severian.db.tar.zst"    "$stage/severian.db"
    cp "$REPO/severian.files.tar.zst" "$stage/severian.files"
    if [[ -f $REPO/severian.db.tar.zst.sig ]];    then cp "$REPO/severian.db.tar.zst.sig"    "$stage/severian.db.sig"; fi
    if [[ -f $REPO/severian.files.tar.zst.sig ]]; then cp "$REPO/severian.files.tar.zst.sig" "$stage/severian.files.sig"; fi

    if ! gh release view "$PUBLISH_TAG" -R "$PUBLISH_REPO" >/dev/null 2>&1; then
        gh release create "$PUBLISH_TAG" -R "$PUBLISH_REPO" --title "SeverianOS packages ($PUBLISH_TAG)" \
            --notes "Binary package repository for SeverianOS, used by pacman. Signed with 614E5176E3257EA92972F3D41CC2187B6745B29E." >/dev/null
        ok "release $PUBLISH_TAG created"
    fi
    gh release upload "$PUBLISH_TAG" "$stage"/* -R "$PUBLISH_REPO" --clobber
    ok "$(find "$stage" -type f | wc -l) files uploaded"

    # remove assets that are no longer part of the repo (old package versions)
    local keep; keep=$(find "$stage" -type f -printf '%f\n')
    while read -r f; do
        [[ -z $f ]] && continue
        grep -qxF -- "$f" <<< "$keep" && continue
        gh release delete-asset "$PUBLISH_TAG" "$f" -R "$PUBLISH_REPO" -y >/dev/null && note "removed old $f"
    done < <(gh release view "$PUBLISH_TAG" -R "$PUBLISH_REPO" --json assets -q '.assets[].name')

    local url="https://github.com/$PUBLISH_REPO/releases/download/$PUBLISH_TAG"
    ok "repo online: $url"
    [[ $REPO_URL == "$url" ]] || note "set REPO_URL=\"$url\" in config.sh, then rebuild (./build.sh all)"
}

release() {
    local tag=v$VERSION iso=$OUT/severianos-$VERSION-x86_64.iso repo notes f
    step "Release SeverianOS $VERSION"
    command -v gh >/dev/null || die "github-cli missing – sudo pacman -S github-cli"
    [[ -f $iso ]] || die "no $iso – run ./build.sh iso first"
    for f in "$iso.sha256" "$iso.b2"; do [[ -f $f ]] || die "missing $f"; done
    if [[ -n $GPG_KEY ]]; then [[ -f $iso.sig ]] || die "missing $iso.sig – rebuild the ISO with GPG_KEY set"; fi
    [[ -z $(git -C "$ROOT" status --porcelain) ]] || die "uncommitted changes – commit first"
    grep -q "^## $VERSION — [0-9]" "$ROOT/CHANGELOG.md" || die "CHANGELOG.md needs a heading '## $VERSION — YYYY-MM-DD'"
    repo=$(cd "$ROOT" && gh repo view --json nameWithOwner -q .nameWithOwner) || die "cannot find the GitHub repo of $ROOT"

    if git -C "$ROOT" rev-parse "$tag" >/dev/null 2>&1; then
        note "tag $tag exists"
    else
        git -C "$ROOT" tag -a "$tag" -m "SeverianOS $VERSION"
        ok "tag $tag created"
    fi
    git -C "$ROOT" push -q origin "$tag"
    ok "tag pushed"

    notes=$BUILD/release-notes.md
    mkdir -p "$BUILD"
    {
        awk -v v="$VERSION" '$0 ~ "^## "v" " {on=1; next} /^## / && on {exit} on' "$ROOT/CHANGELOG.md"
        echo
        echo "### Verify the download"
        echo '```'
        echo "sha256sum -c severianos-$VERSION-x86_64.iso.sha256"
        if [[ -n $GPG_KEY ]]; then
            echo "curl -LO https://raw.githubusercontent.com/$repo/v$VERSION/packages/severian-keyring/files/usr/share/pacman/keyrings/severian.gpg"
            echo "gpg --import severian.gpg"
            echo "gpg --verify severianos-$VERSION-x86_64.iso.sig"
        fi
        echo '```'
        if [[ -n $GPG_KEY ]]; then echo "Signed with \`$GPG_KEY\` (SeverianOS Build Key)."; fi
    } > "$notes"

    local assets=("$iso" "$iso.sha256" "$iso.b2")
    if [[ -f $iso.sig ]]; then assets+=("$iso.sig"); fi
    if gh release view "$tag" -R "$repo" >/dev/null 2>&1; then
        gh release upload "$tag" "${assets[@]}" -R "$repo" --clobber
        ok "files updated in the existing release $tag"
    else
        gh release create "$tag" "${assets[@]}" -R "$repo" --draft \
            --title "SeverianOS $VERSION" --notes-file "$notes" >/dev/null
        ok "DRAFT release $tag created in $repo"
    fi
    note "review it on GitHub, then press 'Publish release'"
}

case ${1:-all} in
    check)    check ;;
    packages) packages ;;
    repo)     repo ;;
    iso)      iso ;;
    all)      check; packages; repo; iso ;;
    publish)  publish ;;
    clean)    sudo rm -rf "$BUILD"; ok "build/ removed" ;;
    release)  release ;;
    *)        sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
