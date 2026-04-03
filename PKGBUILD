# Maintainer: Andreas Trawoeger <atrawog@overthink.net>
pkgname=ov-git
pkgver=2026.93.200
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
)
makedepends=('go' 'git')
optdepends=(
    'docker: alternative container engine'
)
provides=('ov')
conflicts=('ov')
source=("${pkgname}::git+https://github.com/overthinkos/overthink.git")
sha256sums=('SKIP')

pkgver() {
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
}

build() {
    cd "${srcdir}/${pkgname}/ov"
    export GOPATH="${srcdir}/gopath"
    export CGO_ENABLED=0
    go build -trimpath -mod=readonly -o "${srcdir}/ov" .
}

package() {
    install -Dm755 "${srcdir}/ov" "${pkgdir}/usr/bin/ov"
    install -Dm644 "${srcdir}/${pkgname}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
