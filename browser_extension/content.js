(function () {
  if (window.__yuyuCompanionInjected) return;
  window.__yuyuCompanionInjected = true;

  let pill = null;

  // -----------------------------------------------------------------------
  // Firefox için güvenli protokol başlatma:
  //   1. İlk iframe dene (Chrome/Edge + bazı Firefox sayfalarda çalışır)
  //   2. 300ms sonra iframe hâlâ src değerini tutuyorsa başarılı demektir.
  //      Aksi hâlde Firefox'ta window.location kullanmak gerekir ama sekmeyi
  //      kaybetmemek için önce mevcut URL'yi history'e kaydet.
  // -----------------------------------------------------------------------
  function triggerProtocolSilently(protoUrl) {
    // Yöntem 1: gizli iframe (Chrome/Edge + uyumlu Firefox sayfaları)
    try {
      const frame = document.createElement("iframe");
      frame.style.cssText = "display:none;width:0;height:0;border:0;position:absolute;left:-9999px;top:-9999px";
      document.body.appendChild(frame);
      frame.contentWindow.location.href = protoUrl;
      setTimeout(() => {
        try { frame.remove(); } catch (_) {}
      }, 2500);
      return; // iframe yöntemini dene, başarısız olursa kullanıcı popup'a basabilir
    } catch (_) {}

    // Yöntem 2: window.location.href  (son çare — sekme URL'si değişebilir ama
    //           tarayıcı registered protocol varsa uygulamayı açar ve geri gelir)
    try {
      window.location.href = protoUrl;
    } catch (_) {}
  }

  chrome.runtime.onMessage.addListener((msg) => {
    if (msg && msg.action === "launchProtocol" && msg.protoUrl) {
      triggerProtocolSilently(msg.protoUrl);
    }
  });

  // -----------------------------------------------------------------------
  // Sadece gerçek video/içerik sayfalarında buton göster
  // -----------------------------------------------------------------------
  function isDownloadableMediaPage() {
    const host = window.location.hostname.toLowerCase();
    const path = window.location.pathname;
    const search = window.location.search;

    // YouTube: sadece /watch?v=, /shorts/, /live/
    if (host.includes("youtube.com")) {
      return (path === "/watch" && search.includes("v="))
        || path.startsWith("/shorts/")
        || path.startsWith("/live/");
    }
    // Diziwatch: /dizi/.../sezon-X/bolum-Y veya -bolum- içeren URL
    if (host.includes("diziwatch.")) {
      // Ana sayfa, arama, dizi listesi — HİÇBİRİNDE buton çıkmamalı
      // Sadece bölüm sayfalarında: /dizi/seri-adi/sezon-1/bolum-1
      const segments = path.split("/").filter(Boolean);
      return segments.length >= 4 && segments[0] === "dizi";
    }
    if (host.includes("sonanime.com")) {
      return path.includes("/anime/");
    }
    if (host.includes("openani.me")) {
      return path.includes("/anime/");
    }
    if (host.includes("animecix.")) {
      return path.includes("/titles/");
    }
    if (host.includes("tiktok.com")) {
      return path.includes("/video/");
    }
    if (host.includes("instagram.com")) {
      return path.includes("/reel/") || path.includes("/p/");
    }
    if (host.includes("x.com") || host.includes("twitter.com")) {
      return path.includes("/status/");
    }
    if (host.includes("twitch.tv") || host.includes("kick.com")) {
      return path.length > 2 && path !== "/directory";
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Floating pill butonu — DOM'da var olup olmadığını ID ile kontrol et
  // -----------------------------------------------------------------------
  function ensureFloatingButton() {
    if (!document.body) return;

    const shouldShow = isDownloadableMediaPage();

    // DOM'daki mevcut pill'i her seferinde ID ile ara (SPA reset sonrası kaybolabilir)
    const existing = document.getElementById("yuyu-companion-floating-btn");

    if (!shouldShow) {
      if (existing) existing.style.display = "none";
      pill = null; // DOM'dan kalktı mı bilmiyoruz, referansı temizle
      return;
    }

    // Hâlâ DOM'da var → göster
    if (existing) {
      existing.style.display = "inline-flex";
      pill = existing;
      return;
    }

    // Yeniden oluştur
    pill = document.createElement("div");
    pill.id = "yuyu-companion-floating-btn";
    pill.innerHTML = `
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 3v12"></path>
        <path d="m7 10 5 5 5-5"></path>
        <path d="M5 21h14"></path>
      </svg>
      <span>YuYu ile İndir</span>
    `;

    Object.assign(pill.style, {
      position: "fixed",
      bottom: "22px",
      right: "22px",
      zIndex: "2147483646",
      display: "inline-flex",
      alignItems: "center",
      gap: "7px",
      padding: "9px 14px",
      borderRadius: "999px",
      background: "rgba(10, 15, 28, 0.90)",
      backdropFilter: "blur(10px)",
      border: "1px solid rgba(56, 189, 248, 0.45)",
      boxShadow: "0 8px 24px rgba(0, 0, 0, 0.45)",
      color: "#38bdf8",
      fontFamily: "'Segoe UI', system-ui, sans-serif",
      fontSize: "12px",
      fontWeight: "700",
      cursor: "pointer",
      userSelect: "none",
      transition: "transform 0.18s ease, background 0.18s ease, border-color 0.18s ease"
    });

    pill.addEventListener("mouseenter", () => {
      pill.style.transform = "translateY(-2px) scale(1.03)";
      pill.style.background = "rgba(14, 24, 42, 0.96)";
      pill.style.borderColor = "#38bdf8";
    });

    pill.addEventListener("mouseleave", () => {
      pill.style.transform = "translateY(0) scale(1)";
      pill.style.background = "rgba(10, 15, 28, 0.90)";
      pill.style.borderColor = "rgba(56, 189, 248, 0.45)";
    });

    pill.addEventListener("click", () => {
      const span = pill.querySelector("span");
      const originalText = span.textContent;
      span.textContent = "YuYu'da Açılıyor...";
      chrome.runtime.sendMessage({
        action: "sendUrl",
        url: window.location.href,
        autoDownload: false
      }, (res) => {
        if (res && res.needProtocol && res.protoUrl) {
          triggerProtocolSilently(res.protoUrl);
        }
        span.textContent = "Gönderildi!";
        setTimeout(() => {
          span.textContent = originalText;
        }, 1600);
      });
    });

    document.body.appendChild(pill);
  }

  // -----------------------------------------------------------------------
  // SPA navigasyon izleme (YouTube, Diziwatch vb.)
  // -----------------------------------------------------------------------
  let lastHref = window.location.href;

  const navCheck = () => {
    const href = window.location.href;
    if (href !== lastHref) {
      lastHref = href;
      pill = null; // URL değişti, pill referansını sıfırla — DOM kontrol edilecek
      ensureFloatingButton();
    }
  };

  setInterval(navCheck, 500);
  window.addEventListener("yt-navigate-finish", () => { pill = null; ensureFloatingButton(); });
  window.addEventListener("popstate", () => { pill = null; ensureFloatingButton(); });

  if (document.body) {
    ensureFloatingButton();
  } else {
    window.addEventListener("DOMContentLoaded", ensureFloatingButton);
  }
})();
