# Maintainer: Andreas Trawoeger <atrawog@opencharly.ai>
pkgname=opencharly-git
pkgver=2026.163.0758
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
    # The credential store + `charly secrets` CLI are EXTERNALIZED into the
    # bundled candy/plugin-secrets plugin (installed beside charly at
    # /usr/lib/charly/plugins) — the PURE-GO zalando/go-keyring Secret Service
    # client links into THAT plugin binary, not charly's core (which links no
    # go-keyring at all). charly does NOT link libsecret (see optdepends for the
    # optional secret-tool CLI + pinentry-qt Secret Service support). GnuPG is the
    # gpg-preset-passphrase path; pinentry (bundled: pinentry-qt/curses/tty) is
    # the prompt agent the plugin's GPG `.secrets` surface probes for.
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
    # --- SPICE audio: NOT a core dep ---
    # The core charly is cgo-free for audio — it carries no SPICE library at
    # all. The `spice:` check verb and its Shells-com/spice client (the sole
    # opus/portaudio cgo consumers, gated behind `-tags spice_audio`) live in
    # the out-of-tree `candy/plugin-spice`. portaudio/opusfile are therefore
    # deps of that OPTIONAL plugin's spice_audio build, never of this package —
    # so they are intentionally absent here.
    # --- Optional credential / debug / dev / remote-GUI tools (charly runs without them) ---
    'libsecret: secret-tool CLI + pinentry-qt Secret Service passphrase auto-retrieval; the bundled plugin-secrets credential store uses the pure-Go go-keyring D-Bus client'
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

    # The makepkg source clones COMMITTED HEAD into ${srcdir}/${pkgname}, where an UNCOMMITTED
    # candy/plugin-* would be ABSENT — so the DEV plugin build must read the real WORKING tree,
    # exactly as the charly DEV path installs the working-tree-built ${startdir}/../../bin/charly.
    local worktree_root plugin_root
    worktree_root="$(realpath "${startdir}/../..")"

    if [[ -f "${startdir}/../../bin/charly" ]]; then
        # DEV (fast path): the pre-built working-tree charly is ALREADY stamped with
        # main.BuildCalVer by the Taskfile — install it. Build the plugins from the working tree.
        install -Dm755 "${startdir}/../../bin/charly" "${srcdir}/charly"
        plugin_root="${worktree_root}/candy"
    else
        # Standalone/AUR: build charly from the committed clone. Stamp the binary's identity
        # (`charly version` → main.BuildCalVer) with the commit-date CalVer so it equals the
        # pacman pkgver above (without it `charly version` would read the wall clock — useless
        # as a build identity). The core charly carries no SPICE audio code (dep-shed into
        # candy/plugin-spice), so it links no audio libs; CGO stays on for the Go stdlib only.
        # Hermetic GOPATH in the build dir ONLY on this AUR path — the DEV path (above) uses the
        # host GOPATH, so it leaves no read-only Go module cache under ${srcdir} for makepkg's
        # post-build cleanup to choke on (`rm: Permission denied` on the 0444 module cache).
        export GOPATH="${srcdir}/gopath"
        local calver
        calver=$(cd "${srcdir}/${pkgname}" && charly_calver)
        ( cd "${srcdir}/${pkgname}/charly" \
            && CGO_ENABLED=1 go build -trimpath -mod=readonly -ldflags "-X main.BuildCalVer=${calver}" -o "${srcdir}/charly" . )
        plugin_root="${srcdir}/${pkgname}/candy"
    fi

    # Build the BUNDLED EXTERNALIZED plugins beside charly at /usr/lib/charly/plugins:
    #   - plugin-secrets — the credential store (go-keyring + Secret Service) + `charly secrets`
    #     CLI + GPG `.secrets` surface (the C2 dep-shed).
    #   - plugin-udev    — the `charly udev` GPU-device udev-rule manager (the first
    #     externalizable-command precedent; a pure command-only plugin).
    #   - plugin-tmux    — the `charly tmux` persistent-session manager (the first WELDED-command
    #     externalization; re-expresses each leaf as a `charly cmd`/`charly shell` shell-back).
    #   - plugin-preempt — the `charly preempt` exclusive-resource lease inspector/recoverer (the
    #     second WELDED-command externalization; re-expresses each leaf as a shell-back to the
    #     in-core arbiter via the hidden `charly __preempt-status`/`__preempt-restore` verbs).
    #   - plugin-feature — the `charly feature` plan-shaped-description inspector (list/pending/
    #     validate; the third WELDED-command externalization; re-expresses each leaf as a
    #     shell-back to the in-core loader + plan model via the hidden
    #     `charly __feature-list`/`__feature-pending`/`__feature-validate` verbs).
    # Each is built STANDALONE in its own module (GOWORK=off + its `replace …/charly =>
    # ../../charly`), so a project-less HOST charly resolves/syscall.Exec's its commands from
    # /usr/lib/charly/plugins without a project or toolchain. The .providers word manifest is the
    # SINGLE SOURCE (the same list emitBakedPlugins bakes into in-image manifests, via the built
    # charly's __plugin-providers introspection) — NOT the gRPC Describe, which omits the
    # CLI-served command words; discoverBakedPluginWords reads this at startup to register the
    # command/verb words WITHOUT connecting the plugin (the lazy connect is paid only on first use).
    local plugin
    for plugin in plugin-secrets plugin-udev plugin-tmux plugin-preempt plugin-feature; do
        ( cd "${plugin_root}/${plugin}" && GOWORK=off go build -trimpath -o "${srcdir}/${plugin}" . )
        "${srcdir}/charly" __plugin-providers "${plugin_root}/${plugin}" > "${srcdir}/${plugin}.providers"
    done
}

package() {
    install -Dm755 "${srcdir}/charly" "${pkgdir}/usr/bin/charly"
    # The bundled plugins + their `.providers` words manifests, beside the charly binary at the
    # FHS plugin dir (bakedPluginDir). discoverBakedPluginWords reads each manifest at startup to
    # register its words — command:secrets + verb:credential (plugin-secrets), command:udev
    # (plugin-udev), command:tmux (plugin-tmux), command:preempt (plugin-preempt) — WITHOUT
    # connecting the plugin; the lazy connect is paid only on first use.
    local plugin
    for plugin in plugin-secrets plugin-udev plugin-tmux plugin-preempt plugin-feature; do
        install -Dm755 "${srcdir}/${plugin}" "${pkgdir}/usr/lib/charly/plugins/${plugin}"
        install -Dm644 "${srcdir}/${plugin}.providers" "${pkgdir}/usr/lib/charly/plugins/${plugin}.providers"
    done
    install -Dm644 "${srcdir}/${pkgname}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
