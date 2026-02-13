// MAIN world — overrides document.cookie to namespace cookies per workspace.
// The bridge script (ISOLATED world) sets data-devns-ws on <html> with the
// workspace ID. Until that arrives, the override operates in passthrough mode.
;(function () {
  const desc =
    Object.getOwnPropertyDescriptor(Document.prototype, "cookie") ||
    Object.getOwnPropertyDescriptor(HTMLDocument.prototype, "cookie")
  if (!desc) return

  Object.defineProperty(document, "cookie", {
    get() {
      const raw = desc.get.call(this)
      const ws = document.documentElement.dataset.devnsWs
      if (!ws) return raw
      const group = Math.floor((parseInt(ws) - 1) / 10) + 1
      const prefix = `_wg${group}_`
      return raw
        .split("; ")
        .filter((p) => p.split("=")[0].startsWith(prefix))
        .map((p) => p.substring(prefix.length))
        .join("; ")
    },
    set(value) {
      const ws = document.documentElement.dataset.devnsWs
      if (!ws) return desc.set.call(this, value)
      const eq = value.indexOf("=")
      if (eq === -1) return desc.set.call(this, value)
      const group = Math.floor((parseInt(ws) - 1) / 10) + 1
      desc.set.call(this, `_wg${group}_` + value)
    },
    configurable: false,
    enumerable: true,
  })
})()
