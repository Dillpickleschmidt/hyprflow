pkgname=hypr-workflow
pkgver=0.1.0
pkgrel=1
pkgdesc="Visual window group tab overlay for Hyprland"
arch=('any')
license=('MIT')
depends=('python-gobject' 'gtk4-layer-shell' 'hyprland')

package() {
    install -Dm755 "$startdir/hypr-group-overlay" "$pkgdir/usr/bin/hypr-group-overlay"
    install -Dm644 "$startdir/style.css" "$pkgdir/usr/share/hypr-workflow/style.css"
}
