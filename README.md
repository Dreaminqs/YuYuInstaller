# YuYuInstaller

[English](#english) | [Українська](#ukrainian)

YuYuInstaller, modern ve yüksek performanslı bir Windows medya indirme ve dönüştürme yazılımıdır. 4K'ya kadar video indirme, tek tıkla 320 kbps MP3 dönüştürme, güvenli Proxy/Tünel desteği ve akıcı bir anime arayüzü sunar.

> [!NOTE]
> **Otomatik Güncelleme:** Uygulamayı bir kez kurduktan sonra yeni sürümleri uygulama içindeki **Güncellemeler** sekmesinden tek tıkla otomatik olarak alabilirsiniz.

---

## Özellikler

- **Çoklu Platform:** YouTube, Instagram, TikTok, Twitter/X, Facebook, Animecix ve yüzlerce siteden medya indirme.
- **Yüksek Kalite:** 4K UHD, 2K QHD ve 1080p FHD video seçenekleri; video başlığını indirmeden önce düzenleyebilme.
- **320 kbps MP3:** FFmpeg motoru ile stüdyo kalitesinde kayıpsız ses ayıklama.
- **Proxy & Gizli Tünel:** SOCKS5 (Tor, Cloudflare WARP, v2ray) ve HTTP proxy desteği ile okul/yurt ağlarında sansürsüz ve gizli indirme.
- **Akıllı Kuyruk:** İndirme hız sınırı (MB/s), eşzamanlı / sıralı indirme modları ve duraklat/devam et kontrolleri.
- **Çok Dilli:** Türkçe, İngilizce ve Ukraynaca arayüz desteği.

---

## Hızlı Başlangıç

1. [Releases](https://github.com/Dreaminqs/YuYuInstaller/releases/latest) sayfasından `YuYuInstaller_Setup.exe` dosyasını indirip kurun.
2. İndirmek istediğiniz video veya ses linkini yapıştırıp **Analiz Et** butonuna basın.
3. İstediğiniz kaliteyi veya MP3 seçeneğini belirleyip **İndirmeyi Başlat**'a tıklayın.

---

## Kaynak Koddan Derleme

```powershell
git clone https://github.com/Dreaminqs/YuYuInstaller.git
cd YuYuInstaller
.\build.bat        # Uygulamayı derler
.\deploy.bat       # Qt bağımlılıklarını hazırlar
.\make_setup.bat   # Kurulum paketini üretir (Opsiyonel)
```

---

<a id="english"></a>

## English

YuYuInstaller is a high-performance Windows media downloader and audio converter built with modern C++20 and Qt 6. It offers up to 4K video downloads, 1-click 320 kbps MP3 extraction, secure Proxy/Tunnel support, and a fluid dark anime interface.

> [!NOTE]
> **Auto-Update:** Once installed, you don't need to manually download new `.exe` installers. Updates can be installed with 1-click directly from the **Updates** tab.

### Features
- **Multi-Platform:** Download from YouTube, Instagram, TikTok, Twitter/X, Facebook, Animecix, and hundreds of sites.
- **High Resolution:** Up to 4K UHD, 2K QHD, and 1080p FHD video; editable video titles prior to downloading.
- **320 kbps MP3:** Studio-quality audio extraction powered by FFmpeg.
- **Proxy & Stealth Tunnel:** SOCKS5 (Tor, Cloudflare WARP, v2ray) and HTTP proxy support for uncensored and private downloading on campus/dormitory networks.
- **Smart Queue:** Speed limit caps (MB/s), concurrent or sequential modes, pause & resume.
- **Multi-Language:** English, Turkish, and Ukrainian support.

### Quick Start
1. Download and run `YuYuInstaller_Setup.exe` from [Releases](https://github.com/Dreaminqs/YuYuInstaller/releases/latest).
2. Paste a video or audio link and click **Analyze**.
3. Select your desired resolution or MP3 format, then click **Start Download**.

### Build from Source
```powershell
git clone https://github.com/Dreaminqs/YuYuInstaller.git
cd YuYuInstaller
.\build.bat        # Compiles the application
.\deploy.bat       # Deploys Qt runtime binaries
.\make_setup.bat   # Packages the installer (Optional)
```

[↑ Başa Dön / Back to Top](#yuyuinstaller)

---

<a id="ukrainian"></a>

## Українська

YuYuInstaller — сучасний високопродуктивний завантажувач медіа та конвертер аудіо для Windows на базі C++20 та Qt 6. Підтримує завантаження відео до 4K, конвертацію в MP3 320 кбіт/с, безпечний проксі/тунель та плавний аніме-інтерфейс.

> [!NOTE]
> **Автооновлення:** Після встановлення вам не потрібно завантажувати нові файли `.exe` вручну. Оновлення можна встановлювати в один клік безпосередньо у вкладці **Оновлення**.

### Особливості
- **Багатоплатформеність:** Завантаження з YouTube, Instagram, TikTok, Twitter/X, Facebook, Animecix та сотень інших сайтів.
- **Висока якість:** Відео до 4K UHD, 2K QHD та 1080p FHD; можливість перейменування відео перед завантаженням.
- **320 кбіт/с MP3:** Студійна якість вилучення аудіо за допомогою FFmpeg.
- **Проксі та тунелювання:** Підтримка SOCKS5 (Tor, Cloudflare WARP, v2ray) та HTTP проксі для безпечного та вільного завантаження в мережах гуртожитків/кампусів.
- **Розумна черга:** Обмеження швидкості (MB/s), паралельний або послідовний режими, пауза та відновлення.
- **Багатомовність:** Англійська, турецька та українська мови інтерфейсу.

### Швидкий старт
1. Завантажте `YuYuInstaller_Setup.exe` зі сторінки [Releases](https://github.com/Dreaminqs/YuYuInstaller/releases/latest) та встановіть.
2. Вставте посилання на відео або аудіо та натисніть **Аналіз**.
3. Оберіть якість або MP3 та натисніть **Почати завантаження**.

### Збірка з вихідного коду
```powershell
git clone https://github.com/Dreaminqs/YuYuInstaller.git
cd YuYuInstaller
.\build.bat        # Збірка програми
.\deploy.bat       # Розгортання залежностей Qt
.\make_setup.bat   # Створення інсталятора (Опціонально)
```

[↑ Başa Dön / Back to Top](#yuyuinstaller)

---

## Lisans / License

Bu proje [MIT Lisansı](LICENSE) ile lisanslanmıştır.
