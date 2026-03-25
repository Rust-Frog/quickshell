# Maintainer: Custom Build <none@example.com>
pkgname=quickshell-git
pkgver=1.0.0
pkgrel=1
pkgdesc="A quick shell"
arch=('x86_64')
url="https://github.com/quickshell-mirror/quickshell"
license=('GPL')
depends=('qt6-declarative' 'wayland')
makedepends=('spirv-tools' 'qt6-shadertools' 'wayland' 'wayland-protocols' 'cli11' 'ninja' 'cmake' 'git')
provides=('quickshell')
conflicts=('quickshell')
source=("quickshell::git+file:///workspace") # Point to the workspace root in Docker
sha256sums=('SKIP')

pkgver() {
  cd quickshell
  git describe --long --tags --abbrev=7 --exclude='*[a-zA-Z][a-zA-Z]*' 2>/dev/null | sed -E 's/^[^0-9]*//;s/([^-]*-g)/r\1/;s/-/./g' || echo "0.0.0.r$(git rev-list --count HEAD).g$(git rev-parse --short HEAD)"
}

build() {
  cd quickshell
  cmake -GNinja -B build \
    -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DDISTRIBUTOR="Custom" \
    -DDISTRIBUTOR_DEBUGINFO_AVAILABLE=NO \
    -DINSTALL_QML_PREFIX=lib/qt6/qml
  cmake --build build
}

package() {
  cd quickshell
  DESTDIR="$pkgdir" cmake --install build
  install -Dm644 "LICENSE" -t "$pkgdir/usr/share/licenses/quickshell" || true
}
