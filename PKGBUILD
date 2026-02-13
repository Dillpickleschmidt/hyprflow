pkgname=hypr-workflow
pkgver=0.3.0
pkgrel=1
pkgdesc="Hyprland workflow tools: group overlay + per-workspace network namespaces"
arch=('any')
license=('MIT')
depends=('python-gobject' 'gtk4-layer-shell' 'python' 'python-dbus' 'hyprland' 'jq' 'socat' 'iproute2' 'iptables')
backup=('etc/hypr-devns.conf')

package() {
    install -Dm755 "$startdir/group-overlay/hypr-group-overlay" "$pkgdir/usr/bin/hypr-group-overlay"
    install -Dm644 "$startdir/group-overlay/style.css" "$pkgdir/usr/share/hypr-workflow/style.css"

    install -Dm755 "$startdir/devns/hypr-devns-helper" "$pkgdir/usr/bin/hypr-devns-helper"
    install -Dm755 "$startdir/devns/hypr-devns-nsexec" "$pkgdir/usr/bin/hypr-devns-nsexec"
    install -Dm755 "$startdir/devns/hypr-devns-daemon" "$pkgdir/usr/bin/hypr-devns-daemon"
    install -Dm755 "$startdir/devns/hypr-devns-exec" "$pkgdir/usr/bin/hypr-devns-exec"
    install -Dm644 "$startdir/devns/hypr-devns.conf" "$pkgdir/etc/hypr-devns.conf"
    install -Dm440 "$startdir/devns/50-hypr-devns.sudoers" "$pkgdir/etc/sudoers.d/50-hypr-devns"
    install -Dm755 "$startdir/devns/hypr-devns-setup" "$pkgdir/usr/bin/hypr-devns-setup"
    install -Dm755 "$startdir/devns/hypr-devns-disable" "$pkgdir/usr/bin/hypr-devns-disable"
    install -Dm755 "$startdir/devns/hypr-devns-runc" "$pkgdir/usr/bin/hypr-devns-runc"
    install -Dm755 "$startdir/devns/hypr-workspace-group" "$pkgdir/usr/bin/hypr-workspace-group"

    install -Dm644 "$startdir/devns/lib/devns-common.sh" "$pkgdir/usr/share/hypr-workflow/lib/devns-common.sh"

    install -Dm755 "$startdir/devns/hypr-devns-proxy" "$pkgdir/usr/share/hypr-workflow/hypr-devns-proxy"
    install -Dm755 "$startdir/devns/bin/docker" "$pkgdir/usr/share/hypr-workflow/bin/docker"

    install -Dm644 "$startdir/devns/extension/chromium/manifest.json" "$pkgdir/usr/share/hypr-workflow/extension/chromium/manifest.json"
    install -Dm644 "$startdir/devns/extension/chromium/background.js" "$pkgdir/usr/share/hypr-workflow/extension/chromium/background.js"
    install -Dm644 "$startdir/devns/extension/chromium/cookie-isolate-bridge.js" "$pkgdir/usr/share/hypr-workflow/extension/chromium/cookie-isolate-bridge.js"
    install -Dm644 "$startdir/devns/extension/shared/cookie-isolate.js" "$pkgdir/usr/share/hypr-workflow/extension/chromium/cookie-isolate.js"
    install -Dm644 "$startdir/devns/extension/firefox/manifest.json" "$pkgdir/usr/share/hypr-workflow/extension/firefox/manifest.json"
    install -Dm644 "$startdir/devns/extension/firefox/background.js" "$pkgdir/usr/share/hypr-workflow/extension/firefox/background.js"
    install -Dm644 "$startdir/devns/extension/firefox/cookie-isolate-bridge.js" "$pkgdir/usr/share/hypr-workflow/extension/firefox/cookie-isolate-bridge.js"
    install -Dm644 "$startdir/devns/extension/shared/cookie-isolate.js" "$pkgdir/usr/share/hypr-workflow/extension/firefox/cookie-isolate.js"

    install -Dm755 "$startdir/notif/hypr-notif-ws" "$pkgdir/usr/bin/hypr-notif-ws"
}
