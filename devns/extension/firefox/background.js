const PROXY_PORT = 18800

// tabId -> workspace ID (mirrors Chromium's pinnedTabs naming)
const pinnedTabs = new Map()

function savePinnedTabs() {
  browser.storage.local.set({ pinnedTabs: Object.fromEntries(pinnedTabs) })
}

// Restore pinned tabs from storage, filtering out stale tab IDs
browser.tabs.query({}).then((tabs) => {
  const liveIds = new Set(tabs.map((t) => t.id))
  browser.storage.local.get("pinnedTabs").then((result) => {
    const data = result?.pinnedTabs || {}
    let changed = false
    for (const [tabId, wsId] of Object.entries(data)) {
      if (liveIds.has(Number(tabId))) {
        pinnedTabs.set(Number(tabId), wsId)
      } else {
        changed = true
      }
    }
    if (changed) savePinnedTabs()
  })
})

function isLocalhost(hostname) {
  return hostname === "localhost" || hostname === "127.0.0.1"
}

async function fetchActiveWorkspace() {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 3000)
  try {
    const resp = await fetch(`http://127.0.0.1:${PROXY_PORT}/__devns/workspace`, {
      signal: controller.signal,
    })
    if (resp.ok) return (await resp.text()).trim()
  } catch {}
  finally { clearTimeout(timeout) }
  return null
}

// Route localhost requests through the proxy with workspace tagging
browser.proxy.onRequest.addListener(
  (details) => {
    const url = new URL(details.url)
    const port = parseInt(url.port || "80")

    if (!isLocalhost(url.hostname)) return { type: "direct" }
    if (port === PROXY_PORT) return { type: "direct" }
    if (details.type === "speculative") return { type: "direct" }

    const wsId = pinnedTabs.get(details.tabId)
    if (!wsId) return { type: "direct" }

    return {
      type: "http",
      host: "127.0.0.1",
      port: PROXY_PORT,
      proxyAuthorizationHeader: "Basic " + btoa("devns:" + wsId),
    }
  },
  { urls: ["http://localhost/*", "http://127.0.0.1/*"] },
)

// Pin tabs when they first navigate to localhost (kept through external redirects)
browser.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (!changeInfo.url) return
  if (pinnedTabs.has(tabId)) return

  try {
    const url = new URL(changeInfo.url)
    if (isLocalhost(url.hostname) && parseInt(url.port || "80") !== PROXY_PORT) {
      fetchActiveWorkspace().then((wsId) => {
        if (wsId) {
          pinnedTabs.set(tabId, wsId)
          savePinnedTabs()
        }
      })
    }
  } catch {}
})

// Clean up on tab close
browser.tabs.onRemoved.addListener((tabId) => {
  pinnedTabs.delete(tabId)
  savePinnedTabs()
})

// Respond to content script workspace queries
browser.runtime.onMessage.addListener((msg, sender) => {
  if (msg.type === "getWorkspace" && sender.tab) {
    const wsId = pinnedTabs.get(sender.tab.id)
    if (wsId) return Promise.resolve({ wsId })
    return fetchActiveWorkspace().then((ws) => {
      if (ws) {
        pinnedTabs.set(sender.tab.id, ws)
        savePinnedTabs()
      }
      return { wsId: ws }
    })
  }
})
