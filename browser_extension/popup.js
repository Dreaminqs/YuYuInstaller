let currentTab = null;

document.addEventListener("DOMContentLoaded", () => {
  const pageTitleEl = document.getElementById("pageTitle");
  const pageUrlEl = document.getElementById("pageUrl");
  const statusBadgeEl = document.getElementById("statusBadge");
  const statusTextEl = document.getElementById("statusText");
  const toastEl = document.getElementById("toastMsg");
  const btnAnalyze = document.getElementById("btnAnalyze");
  const btnQuickDownload = document.getElementById("btnQuickDownload");

  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    if (tabs && tabs[0]) {
      currentTab = tabs[0];
      pageTitleEl.textContent = currentTab.title || "Medya Sayfası";
      pageUrlEl.textContent = currentTab.url || "";
    }
  });

  chrome.runtime.sendMessage({ action: "pingBridge" }, (res) => {
    if (res && res.online) {
      statusBadgeEl.classList.add("online");
      statusTextEl.textContent = "Masaüstü Bağlı";
    } else {
      statusBadgeEl.classList.remove("online");
      statusTextEl.textContent = "Uygulama Kapalı";
    }
  });

  function triggerSend(autoDownload) {
    if (!currentTab || !currentTab.url) return;
    if (!currentTab.url.startsWith("http://") && !currentTab.url.startsWith("https://")) {
      toastEl.textContent = "Bu sekme desteklenen bir web adresi değil.";
      return;
    }

    toastEl.textContent = "YuYuInstaller'a gönderiliyor...";
    chrome.runtime.sendMessage({
      action: "sendUrl",
      url: currentTab.url,
      autoDownload: autoDownload,
      tabId: currentTab.id
    }, (res) => {
      if (res && res.needProtocol && res.protoUrl) {
        const frame = document.createElement("iframe");
        frame.style.display = "none";
        frame.src = res.protoUrl;
        document.body.appendChild(frame);
      }
      toastEl.textContent = autoDownload
        ? "İndirme kuyruğuna gönderildi!"
        : "YuYuInstaller üzerinde açıldı!";
      setTimeout(() => window.close(), 700);
    });
  }

  btnAnalyze.addEventListener("click", () => triggerSend(false));
  btnQuickDownload.addEventListener("click", () => triggerSend(true));
});
