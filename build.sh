#!/bin/bash
set -euo pipefail

WORKSPACE="${1:-/workspace}"

echo "=== [0/5] Refreshing mirrors ==="
# Force live Arch mirrors (Docker image uses stale snapshot mirrors)
cat > /etc/pacman.d/mirrorlist << 'EOF'
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
EOF

# Initialize pacman keyring (Docker container has no signing keys)
pacman-key --init
pacman-key --populate archlinux

echo "=== [1/5] Installing dependencies ==="
pacman -Syyu --noconfirm --needed \
  cli11 cmake git jemalloc libdrm libpipewire libunwind libxcb mesa ninja polkit \
  qt6-base qt6-declarative qt6-shadertools qt6-svg spirv-tools sudo vulkan-headers wayland wayland-protocols

echo "=== [2/5] Setting up build user ==="
if ! id -u builduser >/dev/null 2>&1; then
    useradd -m builduser
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi
chown -R builduser:builduser "$WORKSPACE"

echo "=== [3/5] Building packages with makepkg ==="
cd "$WORKSPACE"
sudo -u builduser bash -c "export MAKEFLAGS=\"-j\$(nproc)\"; makepkg -s --noconfirm"

echo "=== [4/5] Preparing repository structure ==="
mkdir -p "$WORKSPACE/public/x86_64"

# Copy packages — fail hard if none exist
shopt -s failglob
cp -v "$WORKSPACE"/*.pkg.tar.zst "$WORKSPACE/public/x86_64/"

# Create landing page
cat << 'HTML' > "$WORKSPACE/public/index.html"
<!DOCTYPE html>
<html>
<head><title>Quickshell Pacman Repository</title></head>
<body>
  <h1>Quickshell Custom Pacman Repository</h1>
  <p>Add this to your /etc/pacman.conf:</p>
  <pre>[quickshell]
Server = https://rust-frog.github.io/quickshell/x86_64</pre>
</body>
</html>
HTML

echo "=== [5/5] Creating pacman database with repo-add ==="
cd "$WORKSPACE/public/x86_64"

echo "Files before repo-add:"
ls -lh

# repo-add creates .db and .files as symlinks to .db.tar.gz / .files.tar.gz
repo-add quickshell.db.tar.gz ./*.pkg.tar.zst

echo "Files after repo-add:"
ls -lh

# Verify repo-add actually created the tar.gz files
if [ ! -f quickshell.db.tar.gz ]; then
    echo "ERROR: repo-add failed — quickshell.db.tar.gz not found!"
    exit 1
fi
if [ ! -f quickshell.files.tar.gz ]; then
    echo "ERROR: repo-add failed — quickshell.files.tar.gz not found!"
    exit 1
fi

# GitHub Pages can't follow symlinks, so replace them with real copies
rm -f quickshell.db quickshell.files
cp quickshell.db.tar.gz quickshell.db
cp quickshell.files.tar.gz quickshell.files

echo "Final repository contents:"
ls -lh

# Ensure everything is world-readable for GitHub Pages
chmod -R a+r "$WORKSPACE/public"

echo "=== BUILD COMPLETE ==="
