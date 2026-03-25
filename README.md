# overthink-arch

Arch Linux packaging for [overthink](https://github.com/overthinkos/overthink) — the container management CLI (`ov`).

## Install

### Via yay (from AUR)

```bash
yay -S ov-git
```

### Directly from this repo

```bash
git clone https://github.com/overthinkos/overthink-arch.git
cd overthink-arch
makepkg -si
```

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
| `gocryptfs` | Encrypted bind mount support (`ov enc`) |
| `tailscale` | Tunnel support for deployed services |
| `qemu-full` | VM backend support (`ov vm`) |
| `libvirt` | libvirt VM backend (`ov vm`) |

## Versioning

The package version mirrors the `ov version` CalVer format (`YYYY.DDD.HHMM`) derived from the last commit date. Running `ov version` after install will print the same version that pacman shows in `pacman -Q ov-git`.

## AUR

This package is maintained in the [overthinkos/overthink-arch](https://github.com/overthinkos/overthink-arch) repository and mirrored to the AUR as [`ov-git`](https://aur.archlinux.org/packages/ov-git).
