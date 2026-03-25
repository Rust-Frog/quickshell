# Quickshell — Self-Hosted Fork

A personal fork of [Quickshell](https://quickshell.outfoxxed.me) with an automated CI/CD pipeline that compiles and hosts a custom `pacman` repository on GitHub Pages.

## Why This Fork Exists

Quickshell is a QtQuick-based shell toolkit for Wayland compositors. It is tightly coupled to the exact Qt version it was compiled against — any mismatch causes immediate segmentation faults.

On Arch Linux's rolling-release model, Qt updates land frequently and without warning. If the upstream package isn't recompiled in time, the shell crashes on every login. Rather than waiting on maintainers to rebuild after every Qt bump, this fork:

- **Auto-compiles against the latest stable Qt** on every push via GitHub Actions.
- **Uses live Arch mirrors** (Rackspace, kernel.org) to bypass stale Docker snapshots.
- **Hosts a ready-to-use `pacman` repository** on GitHub Pages — just add it to `/etc/pacman.conf` and go.
- **Ensures users always have a compatible version** of Quickshell, regardless of upstream delays.
- **Provides a transparent view of the build process** through CI logs, so users can see exactly when and how the package is built.
- **Maintains a clean separation from the original project** — this fork is solely focused on providing a reliable Arch package, without modifying the upstream codebase.
- **If you crahsed after a Qt update, this fork is for you** — no more waiting on maintainers to catch up, just a seamless experience with the latest Qt and Quickshell.
- **This fork is not intended to replace the original project** — it exists solely to provide a stable Arch it does auto syncs to the main repo so you don't miss a single thing.
## Installation

Add the repository to `/etc/pacman.conf`:

```ini
[quickshell]
SigLevel = Optional TrustAll
Server = https://rust-frog.github.io/quickshell/x86_64
```

Then install:

```bash
sudo pacman -Sy quickshell-git
```

## How the CI Works

On every push to `master`, a GitHub Action:

1. Spins up an `archlinux:base-devel` Docker container.
2. Injects live Arch mirrors (Rackspace, kernel.org) to bypass stale Docker snapshots.
3. Runs `pacman -Syyu` to fully upgrade the container to the latest stable packages.
4. Compiles Quickshell with `makepkg` and publishes the `.pkg.tar.zst` to `gh-pages`.

## Upstream

This is a fork of [quickshell-mirror/quickshell](https://github.com/quickshell-mirror/quickshell), originally hosted at [git.outfoxxed.me](https://git.outfoxxed.me/quickshell/quickshell).

## License

Licensed under the [GNU LGPL 3](LICENSE).
