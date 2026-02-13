const PROXY_PORT = 18800

// Proxy only localhost/127.0.0.1 HTTP traffic through hypr-devns-proxy.
// <-loopback>: remove implicit loopback bypass. *.*: bypass all real hostnames.
chrome.proxy.settings.set({
  value: {
    mode: "fixed_servers",
    rules: {
      proxyForHttp: { host: "127.0.0.1", port: PROXY_PORT },
      bypassList: ["<-loopback>", "*.*"],
    },
  },
  scope: "regular",
})

// tabId -> workspace ID (in-memory mirror of storage.session)
const pinnedTabs = new Map()

function isLocalhost(url) {
  try {
    const u = new URL(url)
    const host = u.hostname
    const port = parseInt(u.port || "80")
    if (port === PROXY_PORT) return false
    return host === "localhost" || host === "127.0.0.1"
  } catch {
    return false
  }
}

async function getWorkspace() {
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

function setRule(tabId, wsId) {
  const ruleId = tabId
  chrome.declarativeNetRequest.updateSessionRules({
    removeRuleIds: [ruleId],
    addRules: [
      {
        id: ruleId,
        condition: {
          tabIds: [tabId],
          requestDomains: ["localhost", "127.0.0.1"],
          resourceTypes: [
            "main_frame", "sub_frame", "stylesheet", "script", "image",
            "font", "object", "xmlhttprequest", "ping", "media",
            "websocket", "other",
          ],
        },
        action: {
          type: "modifyHeaders",
          requestHeaders: [
            { header: "X-Devns-WS", operation: "set", value: wsId },
          ],
        },
      },
    ],
  })
}

function removeRule(tabId) {
  const ruleId = tabId
  chrome.declarativeNetRequest.updateSessionRules({
    removeRuleIds: [ruleId],
  })
}

function pinTab(tabId, wsId) {
  pinnedTabs.set(tabId, wsId)
  chrome.storage.session.set({ tabWorkspaces: Object.fromEntries(pinnedTabs) })
  setRule(tabId, wsId)
}

function unpinTab(tabId) {
  pinnedTabs.delete(tabId)
  chrome.storage.session.set({ tabWorkspaces: Object.fromEntries(pinnedTabs) })
  removeRule(tabId)
}

// Restore pinned tabs + rules from session storage (service worker restart)
chrome.storage.session.get("tabWorkspaces").then((result) => {
  const data = result?.tabWorkspaces || {}
  chrome.tabs.query({}).then((tabs) => {
    const liveIds = new Set(tabs.map((t) => t.id))
    let changed = false
    for (const [tabId, wsId] of Object.entries(data)) {
      if (liveIds.has(Number(tabId))) {
        pinnedTabs.set(Number(tabId), wsId)
        setRule(Number(tabId), wsId)
      } else {
        changed = true
      }
    }
    if (changed) {
      chrome.storage.session.set({ tabWorkspaces: Object.fromEntries(pinnedTabs) })
    }
  })
})

// Pin tabs when they first navigate to localhost (kept through external redirects)
chrome.tabs.onUpdated.addListener(async (tabId, changeInfo) => {
  if (changeInfo.url && isLocalhost(changeInfo.url) && !pinnedTabs.has(tabId)) {
    const wsId = await getWorkspace()
    if (wsId) pinTab(tabId, wsId)
  }
})

// Clean up on tab close
chrome.tabs.onRemoved.addListener((tabId) => {
  unpinTab(tabId)
})

// Respond to content script workspace queries
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.type === "getWorkspace" && sender.tab) {
    const wsId = pinnedTabs.get(sender.tab.id)
    if (wsId) {
      sendResponse({ wsId })
    } else {
      getWorkspace().then((ws) => {
        if (ws) pinTab(sender.tab.id, ws)
        sendResponse({ wsId: ws })
      })
      return true
    }
  }
})
