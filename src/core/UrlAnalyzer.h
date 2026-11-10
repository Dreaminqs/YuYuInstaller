#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QProcess>
#include "MediaInfo.h"

class UrlAnalyzer : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isAnalyzing READ isAnalyzing NOTIFY analyzingChanged)
    Q_PROPERTY(MediaInfo* currentMediaInfo READ currentMediaInfo NOTIFY mediaInfoChanged)

public:
    explicit UrlAnalyzer(QObject *parent = nullptr);
    ~UrlAnalyzer() override;

    bool isAnalyzing() const { return m_isAnalyzing; }
    MediaInfo* currentMediaInfo() const { return m_currentInfo; }

    Q_INVOKABLE void analyzeUrl(const QString &rawUrl);
    Q_INVOKABLE void clear();
    static QString cleanUrl(const QString &rawUrl);

signals:
    void analyzingChanged();
    void mediaInfoChanged();
    void analysisSuccess(MediaInfo *info);
    void analysisError(const QString &message);

private slots:
    void onHeadFinished();
    void onOembedFinished();
    void onWebPageScrapeFinished();
    void onIframeFetchFinished();
    void onYtDlpFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onSpotifyOembedFinished();
    void onSpotifySearchFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onSoundCloudDrmFinished();
    void onSearchFallbackFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void startSpotifyResolve(const QUrl &url);
    void startSoundCloudDrmFallback(const QUrl &url);
    void startSearchFallback(const QString &searchQuery, const QString &displayTitle, const QString &displayAuthor, const QString &displayThumb, const QString &sourceName);
    void startYouTubeOembedProbe(const QUrl &url);
    void startDiziwatchResolve(const QUrl &url);
    void startPichiveResolve(const QUrl &iframeUrl, const QString &title, const QString &thumb);
    void fetchPichiveSource(const QString &sourceUrl, const QString &iframeUrl, const QString &title, const QString &thumb);
    static QString decryptDiziwatch(const QString &k, const QString &saltHex, const QString &ivHex, const QString &cipherBase64);
    void startSonanimeResolve(const QUrl &url);
    void startAnimecixResolve(const QUrl &url);
    void startTauVideoResolve(const QString &tauId, const QString &animeTitle, int season, int episode, const QString &epName, const QString &poster, const QStringList &fallbackEmbeds = {});
    void startWebPageScrape(const QUrl &url);
    void fetchIframeContent(const QUrl &iframeUrl, const QString &title, const QString &thumb, const QString &providerName);
    void parseHtmlForMedia(const QString &html, const QUrl &baseUrl);
    void startYtDlpProbe(const QString &rawUrl);
    void startDirectProbe(const QUrl &url);
    void startKvsResolve(const QUrl &baseUrl, const QString &videoId, const QString &videoDir, const QString &title, const QString &thumb);
    void resolveMindGeekHls(const QUrl &hlsApiUrl, const QUrl &baseUrl, const QString &title, const QString &thumb);
    void resolveCanliTvAjax(const QUrl &iframeUrl, const QString &vid, const QString &title, const QString &thumb);
    static QString encodeUrlSafely(const QString &raw);
    static QString base164Decode(const QString &rawInput);
    void setupStreamMediaInfo(const QString &streamUrl, const QString &title, const QString &sourceName, const QString &thumbnail = QString(), const QString &referer = QString());
    void populateDirectFileOptions(MediaInfo *info, qint64 sizeBytes, const QString &mimeType, const QString &fileName);
    void populateWebStreamOptions(MediaInfo *info);
    QString extractFileName(const QUrl &url, const QString &contentDisposition);

    bool m_isAnalyzing = false;
    bool m_ytDlpRetried = false;
    bool m_oembedRetried = false;
    MediaInfo *m_currentInfo = nullptr;
    QNetworkAccessManager m_netManager;
    QNetworkReply *m_currentReply = nullptr;
    QProcess *m_ytDlpProcess = nullptr;
    QString m_analyzingUrl;
    QString m_pageReferer;
    QString m_spotifyTitle;
    QString m_spotifyThumb;
    QString m_searchTitle;
    QString m_searchAuthor;
    QString m_searchThumb;
    QString m_searchSource;
    QUrl m_pendingIframeUrl;
    QString m_pendingTitle;
    QString m_pendingThumb;
    QString m_pendingProvider;
};
