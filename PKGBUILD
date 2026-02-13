pkgname=hyprflow
pkgver=0.3.0
pkgrel=1
pkgdesc="Hyprland workflow tools: group overlay + per-workspace network namespaces"
arch=('any')
license=('MIT')
depends=('hyprland' 'jq' 'socat' 'iproute2' 'iptables' 'python' 'gum')
optdepends=(
    'python-gobject: group preview widget'
    'gtk4-layer-shell: group preview widget'
    'python-dbus: workspace numbered notifications'
)
backup=('etc/hypr-devns.conf')

package() {
    install -Dm755 "$startdir/group-overlay/hypr-group-overlay" "$pkgdir/usr/bin/hypr-group-overlay"
    install -Dm644 "$startdir/group-overlay/style.css" "$pkgdir/usr/share/hyprflow/style.css"

    install -Dm755 "$startdir/devns/hypr-devns-helper" "$pkgdir/usr/bin/hypr-devns-helper"
    install -Dm755 "$startdir/devns/hypr-devns-nsexec" "$pkgdir/usr/bin/hypr-devns-nsexec"
    install -Dm755 "$startdir/devns/hypr-devns-daemon" "$pkgdir/usr/bin/hypr-devns-daemon"
    install -Dm755 "$startdir/devns/hypr-devns-exec" "$pkgdir/usr/bin/hypr-devns-exec"
    install -Dm644 "$startdir/devns/hypr-devns.conf" "$pkgdir/etc/hypr-devns.conf"
    install -Dm440 "$startdir/devns/50-hypr-devns.sudoers" "$pkgdir/etc/sudoers.d/50-hypr-devns"
    install -Dm755 "$startdir/install/hyprflow-install" "$pkgdir/usr/bin/hyprflow-install"
    install -Dm644 "$startdir/install/lib/utils.sh" "$pkgdir/usr/share/hyprflow/install/lib/utils.sh"
    for step in "$startdir"/install/steps/*.sh; do
        install -Dm644 "$step" "$pkgdir/usr/share/hyprflow/install/steps/$(basename "$step")"
    done
    install -Dm755 "$startdir/install/hyprflow-uninstall" "$pkgdir/usr/bin/hyprflow-uninstall"
    install -Dm755 "$startdir/devns/hypr-devns-runc" "$pkgdir/usr/bin/hypr-devns-runc"
    install -Dm755 "$startdir/devns/hypr-workspace-group" "$pkgdir/usr/bin/hypr-workspace-group"

    install -Dm644 "$startdir/devns/lib/devns-common.sh" "$pkgdir/usr/share/hyprflow/lib/devns-common.sh"

    install -Dm755 "$startdir/devns/hypr-devns-proxy" "$pkgdir/usr/share/hyprflow/hypr-devns-proxy"
    install -Dm755 "$startdir/devns/bin/docker" "$pkgdir/usr/share/hyprflow/bin/docker"

    install -Dm644 "$startdir/devns/extension/chromium/manifest.json" "$pkgdir/usr/share/hyprflow/extension/chromium/manifest.json"
    install -Dm644 "$startdir/devns/extension/chromium/background.js" "$pkgdir/usr/share/hyprflow/extension/chromium/background.js"
    install -Dm644 "$startdir/devns/extension/chromium/cookie-isolate-bridge.js" "$pkgdir/usr/share/hyprflow/extension/chromium/cookie-isolate-bridge.js"
    install -Dm644 "$startdir/devns/extension/shared/cookie-isolate.js" "$pkgdir/usr/share/hyprflow/extension/chromium/cookie-isolate.js"
    install -Dm644 "$startdir/devns/extension/firefox/manifest.json" "$pkgdir/usr/share/hyprflow/extension/firefox/manifest.json"
    install -Dm644 "$startdir/devns/extension/firefox/background.js" "$pkgdir/usr/share/hyprflow/extension/firefox/background.js"
    install -Dm644 "$startdir/devns/extension/firefox/cookie-isolate-bridge.js" "$pkgdir/usr/share/hyprflow/extension/firefox/cookie-isolate-bridge.js"
    install -Dm644 "$startdir/devns/extension/shared/cookie-isolate.js" "$pkgdir/usr/share/hyprflow/extension/firefox/cookie-isolate.js"

    install -Dm755 "$startdir/notif/hypr-notif-ws" "$pkgdir/usr/bin/hypr-notif-ws"
}
