# overthink-arch

Arch Linux packaging for [overthink](https://github.com/overthinkos/overthink) — the candy-factory container CLI (`ov`).

## Install

`overthink-git` is LOCAL-ONLY — it is NOT published to the AUR, so there is no
`yay -S overthink-git`. Build it from this PKGBUILD directly:

```bash
makepkg -si
```

`makepkg -si` resolves the AUR-only mandatory deps (`cloudflared-bin`,
`gvisor-tap-vsock`) via an AUR helper, or pre-install them first — see the
`makedepends`/AUR notes in the PKGBUILD. From a full overthink checkout, the
equivalent one-liner is `cd pkg/arch && makepkg -si` (or `task build:ov` from
the repo root, which runs the same `makepkg -sefi`).

## Verify

```bash
ov version    # Prints CalVer timestamp (e.g. 2026.84.1241)
ov doctor     # Checks host dependencies
```

## Runtime dependencies

All runtime dependencies are optional — `ov` gracefully degrades when they are absent.

| Package | Purpose |
|---------|---------|
| `docker` or `podman` | Container engine for building and running images |
| `libsecret` | System keyring for credential storage (GNOME/KDE Wallet) |
| `gocryptfs` | Encrypted volume support (`ov config mount/unmount`) |
| `tailscale` | Tunnel support for deployed services |
| `qemu-full` | VM backend support (`ov vm`) |
| `libvirt` | libvirt VM backend (`ov vm`) |

## Versioning

The package version mirrors the `ov version` CalVer format (`YYYY.DDD.HHMM`) derived from the last commit date. Running `ov version` after install will print the same version that pacman shows in `pacman -Q overthink-git`.

## AUR

This package is maintained in the [overthinkos/overthink-arch](https://github.com/overthinkos/overthink-arch) repository and mirrored to the AUR as [`overthink-git`](https://aur.archlinux.org/packages/overthink-git).
