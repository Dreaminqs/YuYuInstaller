const BRIDGE_BASE = "http://127.0.0.1:48652";

function createMenus() {
  chrome.contextMenus.removeAll(() => {
    chrome.contextMenus.create({
      id: "yuyu-analyze-page",
      title: "YuYuInstaller ile Analiz Et (Kalite / Bölüm Seç)",
      contexts: ["page", "frame", "video", "audio"]
    });
    chrome.contextMenus.create({
      id: "yuyu-download-page",
      title: "YuYuInstaller ile Hemen İndir (En Yüksek Kalite)",
      contexts: ["page", "frame", "video", "audio"]
    });
    chrome.contextMenus.create({
      id: "yuyu-analyze-link",
      title: "Bağlantıyı YuYuInstaller'a Gönder",
      contexts: ["link"]
    });
  });
}

chrome.runtime.onInstalled.addListener(createMenus);
if (chrome.runtime.onStartup) {
  chrome.runtime.onStartup.addListener(createMenus);
}

async function sendToDesktopBridge(targetUrl, autoDownload, tabId) {
  if (!targetUrl) return { ok: false };
  const endpoint = autoDownload ? "/download" : "/analyze";
  const bridgeUrl = `${BRIDGE_BASE}${endpoint}?url=${encodeURIComponent(targetUrl)}`;

  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 1200);
    const resp = await fetch(bridgeUrl, {
      method: "GET",
      signal: controller.signal
    });
    clearTimeout(timer);
    if (resp.ok) {
      return { ok: true, via: "bridge" };
    }
  } catch (_) {
    // Desktop app is not running yet; launch via yuyu:// protocol
  }

  const protoMode = autoDownload ? "download" : "analyze";
  const protoUrl = `yuyu://${protoMode}/?url=${encodeURIComponent(targetUrl)}`;
  if (tabId) {
    chrome.tabs.update(tabId, { url: protoUrl });
  } else {
    chrome.tabs.create({ url: protoUrl });
  }
  return { ok: true, via: "protocol" };
}

chrome.contextMenus.onClicked.addListener((info, tab) => {
  const targetUrl = info.linkUrl || info.srcUrl || info.pageUrl || (tab && tab.url) || "";
  if (!targetUrl) return;
  const autoDl = info.menuItemId === "yuyu-download-page";
  sendToDesktopBridge(targetUrl, autoDl, tab ? tab.id : null);
});

chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (!msg || !msg.action) return false;

  if (msg.action === "pingBridge") {
    fetch(`${BRIDGE_BASE}/ping`)
      .then(r => r.json())
      .then(data => sendResponse({ online: Boolean(data && data.ok), version: data.version || "1.2.7" }))
      .catch(() => sendResponse({ online: false }));
    return true;
  }

  if (msg.action === "sendUrl") {
    const tabId = (sender && sender.tab && sender.tab.id) ? sender.tab.id : msg.tabId;
    sendToDesktopBridge(msg.url, Boolean(msg.autoDownload), tabId)
      .then(res => sendResponse(res))
      .catch(() => sendResponse({ ok: false }));
    return true;
  }

  return false;
});
