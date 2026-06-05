# Maintainer: Andreas Trawoeger <atrawog@overthink.net>
pkgname=overthink-git
pkgver=2026.156.453
pkgrel=1
pkgdesc="Overthink container management CLI — compose, build, deploy container boxes from configurable candies"
arch=('x86_64')
url="https://github.com/overthinkos/overthink"
license=('MIT')
install=overthink-git.install
depends=(
    'glibc'
    'podman'
    'docker'         # alternative container engine; coexists with podman
    'gocryptfs'
    'fuse3'
    'openssh'
    'util-linux'     # standard userland (mount, lsblk, etc.) — explicit per ov-cachyos baseline
    'skopeo'
    'qemu-full'
    'qemu-img'
    'virtiofsd'
    'libvirt'
    'tailscale'
    # --- Rootless podman runtime support ---
    # podman declares these as optdepends, but every realistic ov
    # workflow runs rootless and BREAKS without them. Promoting to
    # hard depends so a fresh install Just Works.
    'fuse-overlayfs' # rootless container storage driver
    'slirp4netns'    # rootless container networking
    # --- VM cloud-image support (kind: vm entity; D2/D15/D17) ---
    'libisoburn'     # xorriso — NoCloud cidata seed ISO builder
    'cdrtools'       # genisoimage fallback for the seed ISO builder (cloud_init_iso.go probes xorriso → genisoimage → mkisofs)
    'edk2-ovmf'      # OVMF_CODE + OVMF_VARS for UEFI guests
    'dnsmasq'        # libvirt default-network NAT (when vm uses mode: nat)
    'swtpm'          # software TPM 2.0 (when libvirt.devices.tpm uses backend: emulator)
    # --- Credential surface (ov secrets) ---
    # ov speaks the Secret Service over D-Bus through the PURE-GO
    # zalando/go-keyring client — it does NOT link libsecret (see optdepends
    # for the optional secret-tool CLI + pinentry-qt Secret Service support).
    # GnuPG is the kdbx unlock + gpg-preset-passphrase path; pinentry (bundled:
    # pinentry-qt/curses/tty) is the prompt agent secrets_gpg.go probes for.
    'gnupg'
    'pinentry'
    # --- AUR-only mandatory deps (require yay/paru/AUR helper to install) ---
    # overthink-git itself is LOCAL-ONLY (not on the AUR), so these AUR DEPS
    # can't ride in on a `yay -S overthink-git`. Bare `makepkg -si` cannot
    # resolve them either; `yay -S cloudflared-bin gvisor-tap-vsock` first, or
    # rely on the taskfiles/Build.yml `install` task which pre-installs them via
    # yay before invoking makepkg. NEVER use `yay -B`/`yay -Bi` against the
    # local checkout — that mode runs `git pull` against the pkg/arch
    # subrepo and can reset uncommitted edits in the working tree.
    'cloudflared-bin'  # Cloudflare tunnels (AUR)
    'gvisor-tap-vsock' # podman machine networking (AUR; provides /usr/lib/podman/gvproxy)
)
optdepends=(
    # --- Remote/physical kind:android device support (`target: android` onto
    # an `adb:` endpoint device) ---
    # The in-pod emulator path needs NEITHER of these on the host: apkeep is
    # baked into the android-emulator image and adb runs in-pod (the host
    # speaks the adb wire protocol via goadb). Only a REMOTE/physical device
    # addressed by `kind: android adb: {host: …}` runs apkeep + adb on the
    # HOST. `android-tools` ships the host `adb` (for the `package:` download
    # path's `adb -H -P` install). apkeep has no buildable Arch package (its
    # AUR Rust build fails to link ring/zstd-sys under lld); install it from
    # the upstream precompiled binary on the host when you need the
    # remote-device `package:` (apkeep-download) path — the committed-APK
    # endpoint path (`apk: <file>`) needs neither (pure goadb push).
    'android-tools: host adb for the remote `target: android` package-download install path'
    # --- SPICE audio (opt-in; build ov with `-tags spice_audio`) ---
    # ov embeds Shells-com/spice for the framebuffer/input/cursor/clipboard
    # channels ONLY and never uses audio; its playback/record channels (the
    # sole opus/portaudio cgo consumers) are build-tagged OFF by default, so a
    # plain ov links no audio libs and runs anywhere. Install these AND build
    # ov with `-tags spice_audio` to enable SPICE audio.
    'opusfile: SPICE audio codec, for an ov built with -tags spice_audio'
    'portaudio: SPICE audio I/O, for an ov built with -tags spice_audio'
    # --- Optional credential / debug / dev / remote-GUI tools (ov runs without them) ---
    'libsecret: secret-tool CLI + pinentry-qt Secret Service passphrase auto-retrieval; ov itself uses the pure-Go go-keyring D-Bus client'
    'dmidecode: SMBIOS inspection inside guests when debugging VM key-injection'
    'openbsd-netcat: remote virt-manager/virt-viewer SPICE console over qemu+ssh (ov eval spice connects directly without it)'
    'go-task: provides /usr/bin/task for `task build:ov` and dev workflows from a source checkout'
)
makedepends=(
    'go'
    'git'
    'curl'           # used by `task install`'s portable-fallback path on non-Arch
)
provides=('ov')
conflicts=('ov' 'ov-git')
replaces=('ov-git')
source=("${pkgname}::git+file://$(realpath "${startdir}/../..")")
sha256sums=('SKIP')

pkgver() {
    # The package ships exactly ONE ov binary, so its OWN `ov version` IS the
    # package version — read it directly and pacman's pkgver can NEVER disagree
    # with the installed binary's identity (a parallel re-derivation can: running
    # ov_calver from srcdir/ resolves git to the pkg/arch SUBMODULE, a different
    # commit than the superproject where the ov source lives).
    #
    # Local dev (`task build:ov`) hands us a pre-built, already-stamped bin/ov —
    # the same binary build() installs below; its stamp is the pkgver by
    # construction. AUR/standalone has no bin/ov and builds from the cloned ov
    # source, where ov_calver derives the same commit-date CalVer build()'s ldflag
    # will bake — so pkgver == `ov version` there too.
    if [[ -x "${startdir}/../../bin/ov" ]]; then
        "${startdir}/../../bin/ov" version 2>/dev/null
        return
    fi
    # shellcheck source=calver.sh
    source "${startdir}/calver.sh"
    cd "${srcdir}/${pkgname}"
    ov_calver
}

build() {
    # shellcheck source=calver.sh
    source "${startdir}/calver.sh"
    # Use pre-built binary from `task build:ov` if available (fast dev path).
    # That binary is ALREADY stamped with main.BuildCalVer by the Taskfile, so
    # no ldflag injection is needed here — just install it.
    if [[ -f "${startdir}/../../bin/ov" ]]; then
        install -Dm755 "${startdir}/../../bin/ov" "${srcdir}/ov"
        return
    fi
    # Standalone/AUR: build from git source. Stamp the binary's identity
    # (`ov version` → main.BuildCalVer) with the commit-date CalVer so it equals
    # the pacman pkgver above. Without this, `ov version` would read the wall
    # clock at invocation time — useless as a build identity / freshness signal.
    local calver
    calver=$(cd "${srcdir}/${pkgname}" && ov_calver)
    cd "${srcdir}/${pkgname}/ov"
    export GOPATH="${srcdir}/gopath"
    # The only cgo in ov was the Shells-com/spice audio channels (portaudio +
    # opus); they are now gated behind the `spice_audio` build tag (default
    # OFF), so this plain build links no audio libs and runs on any glibc
    # system. CGO stays enabled for the Go stdlib (net/os); build ov with
    # `-tags spice_audio` (and opusfile + portaudio installed) for SPICE audio.
    export CGO_ENABLED=1
    go build -trimpath -mod=readonly -ldflags "-X main.BuildCalVer=${calver}" -o "${srcdir}/ov" .
}

package() {
    install -Dm755 "${srcdir}/ov" "${pkgdir}/usr/bin/ov"
    install -Dm644 "${srcdir}/${pkgname}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
