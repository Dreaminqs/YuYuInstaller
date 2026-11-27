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

async function sendToDesktopBridge(targetUrl, autoDownload) {
  if (!targetUrl) return { ok: false };
  const endpoint = autoDownload ? "/download" : "/analyze";
  const bridgeUrl = `${BRIDGE_BASE}${endpoint}?url=${encodeURIComponent(targetUrl)}`;

  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 1400);
    const resp = await fetch(bridgeUrl, {
      method: "GET",
      signal: controller.signal
    });
    clearTimeout(timer);
    if (resp.ok) {
      return { ok: true, via: "bridge" };
    }
  } catch (_) {
    // Desktop app is not running yet
  }

  return {
    ok: false,
    needProtocol: true,
    protoUrl: `yuyu://${autoDownload ? "download" : "analyze"}/?url=${encodeURIComponent(targetUrl)}`
  };
}

chrome.contextMenus.onClicked.addListener((info, tab) => {
  const targetUrl = info.linkUrl || info.srcUrl || info.pageUrl || (tab && tab.url) || "";
  if (!targetUrl) return;
  const autoDl = info.menuItemId === "yuyu-download-page";
  sendToDesktopBridge(targetUrl, autoDl).then(res => {
    if (res && res.needProtocol && tab && tab.id) {
      chrome.tabs.sendMessage(tab.id, { action: "launchProtocol", protoUrl: res.protoUrl });
    }
  });
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
    sendToDesktopBridge(msg.url, Boolean(msg.autoDownload))
      .then(res => sendResponse(res))
      .catch(() => sendResponse({ ok: false }));
    return true;
  }

  return false;
});
