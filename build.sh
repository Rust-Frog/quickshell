#!/bin/bash
set -ex

# Update and install dependencies
pacman -Sy --noconfirm --needed \
  cli11 cmake git jemalloc libdrm libpipewire libunwind libxcb mesa ninja polkit \
  qt6-base qt6-declarative qt6-shadertools qt6-svg spirv-tools sudo vulkan-headers wayland wayland-protocols

# Provide non-root user for makepkg
if ! id -u builduser >/dev/null 2>&1; then
    useradd -m builduser
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi
chown -R builduser:builduser .

# Execute makepkg as builduser
sudo -u builduser bash -c 'export MAKEFLAGS="-j$(nproc)"; makepkg -s --noconfirm'

# Prepare public directory
mkdir -p public/x86_64
cp -v *.pkg.tar.zst public/x86_64/

# Create landing page
cat << 'HTML' > public/index.html
<!DOCTYPE html>
<html>
<head><title>Quickshell Pacman Repository</title></head>
<body>
  <h1>Quickshell Custom Pacman Repository</h1>
  <p>Add this to your /etc/pacman.conf:</p>
  <pre>[quickshell]<br>Server = https://rust-frog.github.io/quickshell/x86_64</pre>
</body>
</html>
HTML

# Run repo-add as root
cd public/x86_64
repo-add quickshell.db.tar.gz *.pkg.tar.zst

# Prepare real files
rm -f quickshell.db quickshell.files
cp -v quickshell.db.tar.gz quickshell.db
cp -v quickshell.files.tar.gz quickshell.files

# Final check
ls -lh

# Final permissions
chmod -R 777 /workspace/public
