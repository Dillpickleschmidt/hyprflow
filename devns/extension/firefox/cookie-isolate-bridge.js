// ISOLATED world — gets workspace ID from background and exposes it to the page.
// See also: ../chromium/cookie-isolate-bridge.js (callback-based equivalent)
browser.runtime
  .sendMessage({ type: "getWorkspace" })
  .then((response) => {
    if (response?.wsId) {
      document.documentElement.dataset.devnsWs = response.wsId
    }
  })
  .catch(() => {})
