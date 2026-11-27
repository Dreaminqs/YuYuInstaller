(function () {
  if (window.__yuyuCompanionInjected) return;
  window.__yuyuCompanionInjected = true;

  let pill = null;

  function createFloatingButton() {
    if (document.getElementById("yuyu-companion-floating-btn")) return;

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
      background: "rgba(10, 15, 28, 0.88)",
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
      pill.style.background = "rgba(10, 15, 28, 0.88)";
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
      }, () => {
        span.textContent = "Gönderildi!";
        setTimeout(() => {
          span.textContent = originalText;
        }, 1600);
      });
    });

    document.body.appendChild(pill);
  }

  if (document.body) {
    createFloatingButton();
  } else {
    window.addEventListener("DOMContentLoaded", createFloatingButton);
  }
})();
