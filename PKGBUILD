# Maintainer: Andreas Trawoeger <atrawog@opencharly.ai>
pkgname=opencharly-git
pkgver=2026.162.2035
pkgrel=1
pkgdesc="OpenCharly container management CLI — compose, build, deploy container boxes from configurable candies"
arch=('x86_64')
url="https://github.com/overthinkos/overthink"
license=('MIT')
install=opencharly-git.install
depends=(
    # POLICY: every tool charly invokes that lives in the cachyos/arch REPOS is a
    # mandatory dep here (a fresh `pacman -S opencharly-git` Just Works), with the
    # sole exceptions carved out to optdepends below: Docker (alternative engine),
    # the AUR-only tools, and the GPU/k8s situational tools (nvidia-utils, kubectl).
    'glibc'
    'podman'
    'gocryptfs'
    'fuse3'
    'openssh'
    'util-linux'     # standard userland (mount, lsblk, etc.) — explicit per charly-cachyos baseline
    'skopeo'
    'qemu-full'
    'qemu-img'
    'virtiofsd'
    'libvirt'
    'tailscale'
    'libarchive'     # bsdtar — reads .PKGINFO from a built .pkg.tar.zst in the localpkg dependency resolver (localpkg.go)
    'iproute2'       # ss — CDP/port readiness probes (cdp.go)
    # --- Rootless podman runtime support ---
    # podman declares these as optdepends, but every realistic charly
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
    # --- Credential surface (charly secrets) ---
    # charly speaks the Secret Service over D-Bus through the PURE-GO
    # zalando/go-keyring client — it does NOT link libsecret (see optdepends
    # for the optional secret-tool CLI + pinentry-qt Secret Service support).
    # GnuPG is the kdbx unlock + gpg-preset-passphrase path; pinentry (bundled:
    # pinentry-qt/curses/tty) is the prompt agent secrets_gpg.go probes for.
    'gnupg'
    'pinentry'
)
optdepends=(
    # --- Container engine alternative (podman is the mandatory default) ---
    'docker: alternative container engine — only needed for engine.run=docker (podman is the default)'
    # --- AUR-only integrations (NOT in the cachyos/arch repos; install via an AUR helper when the feature is used) ---
    # opencharly-git is LOCAL-ONLY, so these can't ride in on a `yay -S opencharly-git`;
    # `yay -S cloudflared-bin gvisor-tap-vsock` when you need tunnels / podman-machine networking.
    'cloudflared-bin: Cloudflare tunnels (AUR)'
    'gvisor-tap-vsock: podman-machine networking — provides /usr/lib/podman/gvproxy (AUR)'
    # --- GPU passthrough (repo-available, but only used when a kind:vm passes a GPU or a deploy generates CDI) ---
    'nvidia-utils: nvidia-smi GPU detection + nvidia-ctk CDI generation (GPU targets only)'
    # --- Kubernetes (repo-available, but only used for kind:k8s targets) ---
    'kubectl: Kubernetes deploys + charly eval k8s probes (kind:k8s targets only)'
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
    # --- SPICE audio (opt-in; build charly with `-tags spice_audio`) ---
    # charly embeds Shells-com/spice for the framebuffer/input/cursor/clipboard
    # channels ONLY and never uses audio; its playback/record channels (the
    # sole opus/portaudio cgo consumers) are build-tagged OFF by default, so a
    # plain charly links no audio libs and runs anywhere. Install these AND build
    # charly with `-tags spice_audio` to enable SPICE audio.
    'opusfile: SPICE audio codec, for a charly built with -tags spice_audio'
    'portaudio: SPICE audio I/O, for a charly built with -tags spice_audio'
    # --- Optional credential / debug / dev / remote-GUI tools (charly runs without them) ---
    'libsecret: secret-tool CLI + pinentry-qt Secret Service passphrase auto-retrieval; charly itself uses the pure-Go go-keyring D-Bus client'
    'dmidecode: SMBIOS inspection inside guests when debugging VM key-injection'
    'openbsd-netcat: remote virt-manager/virt-viewer SPICE console over qemu+ssh (charly eval spice connects directly without it)'
    'go-task: provides /usr/bin/task for `task build:charly` and dev workflows from a source checkout'
)
makedepends=(
    'go'
    'git'
    'curl'           # used by `task install`'s portable-fallback path on non-Arch
)
provides=('charly')
conflicts=('overthink-git' 'ov-git')
replaces=('overthink-git' 'ov-git')
source=("${pkgname}::git+file://$(realpath "${startdir}/../..")")
sha256sums=('SKIP')

pkgver() {
    # The package ships exactly ONE charly binary, so its OWN `charly version` IS
    # the package version — read it directly and pacman's pkgver can NEVER disagree
    # with the installed binary's identity (a parallel re-derivation can: running
    # charly_calver from srcdir/ resolves git to the pkg/arch SUBMODULE, a different
    # commit than the superproject where the charly source lives).
    #
    # Local dev (`task build:charly`) hands us a pre-built, already-stamped
    # bin/charly — the same binary build() installs below; its stamp is the pkgver
    # by construction. AUR/standalone has no bin/charly and builds from the cloned
    # charly source, where charly_calver derives the same commit-date CalVer
    # build()'s ldflag will bake — so pkgver == `charly version` there too.
    if [[ -x "${startdir}/../../bin/charly" ]]; then
        "${startdir}/../../bin/charly" version 2>/dev/null
        return
    fi
    # shellcheck source=calver.sh
    source "${startdir}/calver.sh"
    cd "${srcdir}/${pkgname}"
    charly_calver
}

build() {
    # shellcheck source=calver.sh
    source "${startdir}/calver.sh"
    # Use pre-built binary from `task build:charly` if available (fast dev path).
    # That binary is ALREADY stamped with main.BuildCalVer by the Taskfile, so
    # no ldflag injection is needed here — just install it.
    if [[ -f "${startdir}/../../bin/charly" ]]; then
        install -Dm755 "${startdir}/../../bin/charly" "${srcdir}/charly"
        return
    fi
    # Standalone/AUR: build from git source. Stamp the binary's identity
    # (`charly version` → main.BuildCalVer) with the commit-date CalVer so it
    # equals the pacman pkgver above. Without this, `charly version` would read the
    # wall clock at invocation time — useless as a build identity / freshness signal.
    local calver
    calver=$(cd "${srcdir}/${pkgname}" && charly_calver)
    cd "${srcdir}/${pkgname}/charly"
    export GOPATH="${srcdir}/gopath"
    # The only cgo in charly was the Shells-com/spice audio channels (portaudio +
    # opus); they are now gated behind the `spice_audio` build tag (default
    # OFF), so this plain build links no audio libs and runs on any glibc
    # system. CGO stays enabled for the Go stdlib (net/os); build charly with
    # `-tags spice_audio` (and opusfile + portaudio installed) for SPICE audio.
    export CGO_ENABLED=1
    go build -trimpath -mod=readonly -ldflags "-X main.BuildCalVer=${calver}" -o "${srcdir}/charly" .
}

package() {
    install -Dm755 "${srcdir}/charly" "${pkgdir}/usr/bin/charly"
    install -Dm644 "${srcdir}/${pkgname}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
