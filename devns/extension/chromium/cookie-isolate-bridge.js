// ISOLATED world — gets workspace ID from background and exposes it to the page.
// See also: ../firefox/cookie-isolate-bridge.js (promise-based equivalent)
chrome.runtime.sendMessage({ type: "getWorkspace" }, (response) => {
  if (chrome.runtime.lastError) return
  if (response?.wsId) {
    document.documentElement.dataset.devnsWs = response.wsId
  }
})
