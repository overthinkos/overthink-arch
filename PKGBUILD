# Maintainer: Andreas Trawoeger <atrawog@overthink.net>
pkgname=ov-git
pkgver=2026.121.1124
pkgrel=1
pkgdesc="Overthink container management CLI — compose, build, deploy container images from configurable layers"
arch=('x86_64')
url="https://github.com/overthinkos/overthink"
license=('MIT')
depends=(
    'glibc'
    'podman'
    'libsecret'
    'gocryptfs'
    'fuse3'
    'openssh'
    'skopeo'
    'qemu-full'
    'qemu-img'
    'virtiofsd'
    'libvirt'
    'tailscale'
    # --- VM cloud-image support (kind: vm entity; D2/D15/D17) ---
    'libisoburn'     # xorriso — NoCloud cidata seed ISO builder
    'edk2-ovmf'      # OVMF_CODE + OVMF_VARS for UEFI guests
    'dnsmasq'        # libvirt default-network NAT (when vm uses mode: nat)
    'swtpm'          # software TPM 2.0 (when libvirt.devices.tpm uses backend: emulator)
    'dmidecode'      # SMBIOS inspection inside guests (debugging key-injection)
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
)
makedepends=(
    'go'
    'git'
    'pkgconf'        # cgo pkg-config lookup for portaudio + opus during compile
)
optdepends=(
    'docker: alternative container engine'
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
