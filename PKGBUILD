# Maintainer: Custom Build <none@example.com>
pkgname=quickshell-git
pkgver=1.0.0
pkgrel=1
pkgdesc="A quick shell"
arch=('x86_64')
url="https://github.com/quickshell-mirror/quickshell"
license=('GPL')
depends=('qt6-declarative' 'qt6-base' 'jemalloc' 'qt6-svg' 'libpipewire' 'libxcb' 'wayland' 'libdrm' 'mesa' 'polkit')
makedepends=('spirv-tools' 'qt6-shadertools' 'wayland-protocols' 'cli11' 'ninja' 'cmake' 'git' 'vulkan-headers' 'libunwind')
provides=('quickshell')
conflicts=('quickshell')
source=("quickshell::git+file:///workspace") # Point to the workspace root in Docker
sha256sums=('SKIP')

pkgver() {
  git -C "$srcdir/quickshell" rev-list --count HEAD
}

build() {
  cd quickshell
  cmake -GNinja -B build \
    -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DDISTRIBUTOR="Custom" \
    -DDISTRIBUTOR_DEBUGINFO_AVAILABLE=NO \
    -DINSTALL_QML_PREFIX=lib/qt6/qml \
    -DVENDOR_CPPTRACE=ON
  cmake --build build
}

package() {
  cd quickshell
  DESTDIR="$pkgdir" cmake --install build
  install -Dm644 "LICENSE" -t "$pkgdir/usr/share/licenses/quickshell" || true

  # Remove vendored headers/libs that conflict with system packages
  # (cpptrace, zstd, libdwarf, libelf)
  rm -rf "$pkgdir"/usr/include/cpptrace
  rm -rf "$pkgdir"/usr/include/ctrace
  rm -f  "$pkgdir"/usr/include/dwarf.h
  rm -f  "$pkgdir"/usr/include/zdict.h
  rm -f  "$pkgdir"/usr/include/zstd.h
  rm -f  "$pkgdir"/usr/include/zstd_errors.h
  rm -rf "$pkgdir"/usr/lib/cmake/cpptrace
  rm -rf "$pkgdir"/usr/lib/cmake/zstd
  rm -f  "$pkgdir"/usr/lib/pkgconfig/libdwarf.pc
  rm -f  "$pkgdir"/usr/lib/pkgconfig/libzstd.pc
}
