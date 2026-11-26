#pragma once

#include <QQuickItem>
#include <QTimer>
#include <QImage>
#include <QString>
#include <QThread>
#include <atomic>

struct IMFSourceReader;
class QSGNode;

// Decodes video frames with Media Foundation on a dedicated worker thread,
// so the GUI thread (animations, scrolling) is never blocked by decoding.
class VideoDecoderWorker : public QObject {
    Q_OBJECT
public:
    explicit VideoDecoderWorker(QObject *parent = nullptr);
    ~VideoDecoderWorker() override;

    // Called from the GUI thread once a frame has been consumed (frame dropping).
    void markConsumed() { m_inFlight.store(false); }

public slots:
    void open(const QString &path, int targetFps);
    void setPlaying(bool playing);
    void setTargetFps(int fps);
    void shutdown();

signals:
    void frameReady(const QImage &frame);

private slots:
    void tick();

private:
    void closeMedia();
    void readNextFrame();
    void restartTimer();

    QTimer *m_timer = nullptr;
    IMFSourceReader *m_reader = nullptr;
    int m_videoWidth = 0;
    int m_videoHeight = 0;
    int m_intervalMs = 16;
    bool m_playing = false;
    bool m_mfInitialized = false;
    bool m_comInitialized = false;
    std::atomic_bool m_inFlight { false };
};

class VideoBackgroundItem : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool playing READ isPlaying WRITE setPlaying NOTIFY playingChanged)
    Q_PROPERTY(int targetFps READ targetFps WRITE setTargetFps NOTIFY targetFpsChanged)

public:
    explicit VideoBackgroundItem(QQuickItem *parent = nullptr);
    ~VideoBackgroundItem() override;

    QString source() const { return m_source; }
    void setSource(const QString &source);

    bool isPlaying() const { return m_playing; }
    void setPlaying(bool play);

    int targetFps() const { return m_targetFps; }
    void setTargetFps(int fps);

signals:
    void sourceChanged();
    void playingChanged();
    void targetFpsChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *data) override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private slots:
    void onFrameReady(const QImage &frame);

private:
    QString resolvePath(const QString &source) const;

    QString m_source;
    bool m_playing = true;
    int m_targetFps = 60;

    QImage m_frame;
    bool m_frameDirty = false;

    QThread m_thread;
    VideoDecoderWorker *m_worker = nullptr;
};
