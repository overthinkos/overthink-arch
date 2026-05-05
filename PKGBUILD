# Maintainer: Andreas Trawoeger <atrawog@overthink.net>
pkgname=ov-git
pkgver=2026.125.822
pkgrel=1
pkgdesc="Overthink container management CLI — compose, build, deploy container images from configurable layers"
arch=('x86_64')
url="https://github.com/overthinkos/overthink"
license=('MIT')
install=ov-git.install
depends=(
    'glibc'
    'podman'
    'docker'         # alternative container engine; coexists with podman
    'libsecret'
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
    # --- Build tool (canonical user-facing build flow `task build:ov`) ---
    'go-task'        # provides /usr/bin/task — required by `task build:ov` and other dev workflows from a checkout
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
    'dmidecode'      # SMBIOS inspection inside guests (debugging key-injection)
    # --- Credential surface (ov secrets, KeePass + secret-tool path) ---
    # GnuPG is the kdbx unlock and gpg-preset-passphrase fallback;
    # pinentry (bundled package; provides pinentry-qt + pinentry-curses
    # + pinentry-tty etc.) is the prompt agent secrets_gpg.go probes for.
    'gnupg'
    'pinentry'
    # --- SPICE client support (`ov test spice`, Shells-com/spice library) ---
    # Shells-com/spice's playback/record channels use cgo bindings to
    # portaudio + opusfile. Both are required at link time AND runtime.
    # opusfile pulls libogg + openssl + opus transitively.
    'portaudio'      # gordonklaus/portaudio → libportaudio (audio I/O)
    'opusfile'       # hraban/opus → libopusfile + libopus (Opus audio codec)
    # --- Remote-GUI access to VMs with <listen type='socket'/> SPICE ---
    # virt-viewer / virt-manager's auto SSH tunnel for UNIX-socket
    # SPICE listeners works by spawning `ssh host nc -U <socket>` on
    # the libvirt host. Without `nc` (openbsd-netcat), remote
    # `virt-manager --connect qemu+ssh://host/session` silently fails
    # to open the console.
    'openbsd-netcat'
    # --- AUR-only mandatory deps (require yay/paru/AUR helper to install) ---
    # Bare `makepkg -si` cannot resolve these; use `yay -S ov-git` /
    # `yay -S cloudflared-bin gvisor-tap-vsock` first, or rely on the
    # taskfiles/Build.yml `install` task which pre-installs them via yay
    # before invoking makepkg. NEVER use `yay -B`/`yay -Bi` against the
    # local checkout — that mode runs `git pull` against the pkg/arch
    # subrepo and can reset uncommitted edits in the working tree.
    'cloudflared-bin'  # Cloudflare tunnels (AUR)
    'gvisor-tap-vsock' # podman machine networking (AUR; provides /usr/lib/podman/gvproxy)
)
makedepends=(
    'go'
    'git'
    'pkgconf'        # cgo pkg-config lookup for portaudio + opus during compile
    'curl'           # used by `task install`'s portable-fallback path on non-Arch
)
provides=('ov')
conflicts=('ov')
source=("${pkgname}::git+file://$(realpath "${startdir}/../..")")
sha256sums=('SKIP')

pkgver() {
    if [[ -d "${srcdir}/${pkgname}/.git" ]]; then
        cd "${srcdir}/${pkgname}"
        # Derive CalVer from last commit date — matches `ov version` output format exactly.
        # Format: YYYY.DDD.HHMM where DDD=day-of-year (no leading zeros), HHMM=hour*100+min
        local commit_date
        commit_date=$(git log -1 --format="%cd" --date=format-local:"%Y %j %H %M")
        read -r year day hour min <<< "$commit_date"
        # Strip leading zeros so bash arithmetic works correctly
        day=$((10#$day))
        hour=$((10#$hour))
        min=$((10#$min))
        hhmm=$((hour * 100 + min))
        printf "%d.%d.%d" "$year" "$day" "$hhmm"
    else
        # Local dev install — use current date
        date -u '+%Y.%-j.%-H%M'
    fi
}

build() {
    # Use pre-built binary from task build:ov if available (fast dev path)
    if [[ -f "${startdir}/../../bin/ov" ]]; then
        install -Dm755 "${startdir}/../../bin/ov" "${srcdir}/ov"
        return
    fi
    # Standalone/AUR: build from git source
    cd "${srcdir}/${pkgname}/ov"
    export GOPATH="${srcdir}/gopath"
    # cgo required by Shells-com/spice audio channels (portaudio + opus).
    # The rest of ov is pure Go; we cannot CGO_ENABLED=0 anymore because
    # the spice import transitively pulls portaudio/opus cgo bindings.
    export CGO_ENABLED=1
    go build -trimpath -mod=readonly -o "${srcdir}/ov" .
}

package() {
    install -Dm755 "${srcdir}/ov" "${pkgdir}/usr/bin/ov"
    install -Dm644 "${srcdir}/${pkgname}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
