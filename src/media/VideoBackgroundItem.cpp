#include "VideoBackgroundItem.h"

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <objbase.h>
#include <mfapi.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <mferror.h>
#include <propvarutil.h>

#include <QCoreApplication>
#include <QQuickWindow>
#include <QSGImageNode>
#include <QSGTexture>
#include <QFileInfo>
#include <QDir>
#include <QUrl>
#include <QDebug>

// ═══════════════════════════════════════════════════════════════
// VideoDecoderWorker (runs on its own thread)
// ═══════════════════════════════════════════════════════════════

VideoDecoderWorker::VideoDecoderWorker(QObject *parent)
    : QObject(parent)
{
}

VideoDecoderWorker::~VideoDecoderWorker() {
    // shutdown() is expected to have been called on the worker thread.
}

void VideoDecoderWorker::open(const QString &path, int targetFps) {
    closeMedia();

    if (!m_timer) {
        m_timer = new QTimer(this);
        m_timer->setTimerType(Qt::PreciseTimer);
        connect(m_timer, &QTimer::timeout, this, &VideoDecoderWorker::tick);
    }

    if (!m_comInitialized) {
        HRESULT hrCo = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
        m_comInitialized = SUCCEEDED(hrCo);
    }

    if (!m_mfInitialized) {
        HRESULT hrMf = MFStartup(MF_VERSION, MFSTARTUP_NOSOCKET);
        if (FAILED(hrMf)) {
            qWarning() << "[VideoBackground] MFStartup failed:" << hrMf;
            return;
        }
        m_mfInitialized = true;
    }

    if (path.isEmpty() || !QFileInfo::exists(path)) {
        qWarning() << "[VideoBackground] Video file not found:" << path;
        return;
    }

    IMFAttributes *pAttributes = nullptr;
    MFCreateAttributes(&pAttributes, 2);
    if (pAttributes) {
        pAttributes->SetUINT32(MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING, TRUE);
        pAttributes->SetUINT32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS, TRUE);
    }

    std::wstring wpath = QDir::toNativeSeparators(path).toStdWString();
    HRESULT hr = MFCreateSourceReaderFromURL(wpath.c_str(), pAttributes, &m_reader);
    if (pAttributes) pAttributes->Release();

    if (FAILED(hr) || !m_reader) {
        qWarning() << "[VideoBackground] Failed to create IMFSourceReader, hr:" << hr;
        m_reader = nullptr;
        return;
    }

    m_reader->SetStreamSelection(static_cast<DWORD>(MF_SOURCE_READER_ALL_STREAMS), FALSE);
    m_reader->SetStreamSelection(static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM), TRUE);

    IMFMediaType *pMediaType = nullptr;
    if (SUCCEEDED(MFCreateMediaType(&pMediaType))) {
        pMediaType->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video);
        pMediaType->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32);
        m_reader->SetCurrentMediaType(static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM), nullptr, pMediaType);
        pMediaType->Release();
    }

    IMFMediaType *pCurrentType = nullptr;
    if (SUCCEEDED(m_reader->GetCurrentMediaType(static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM), &pCurrentType))) {
        UINT32 w = 0, h = 0;
        MFGetAttributeSize(pCurrentType, MF_MT_FRAME_SIZE, &w, &h);
        m_videoWidth = static_cast<int>(w);
        m_videoHeight = static_cast<int>(h);
        pCurrentType->Release();
    }

    setTargetFps(targetFps);

    // Show the first frame immediately, even if paused.
    m_inFlight.store(false);
    readNextFrame();
    restartTimer();
}

void VideoDecoderWorker::setPlaying(bool playing) {
    m_playing = playing;
    restartTimer();
}

void VideoDecoderWorker::setTargetFps(int fps) {
    int clamped = qBound(10, fps, 60);
    m_intervalMs = qMax(1, qRound(1000.0 / clamped));
    restartTimer();
}

void VideoDecoderWorker::restartTimer() {
    if (!m_timer) return;
    if (m_playing && m_reader) {
        m_timer->start(m_intervalMs);
    } else {
        m_timer->stop();
    }
}

void VideoDecoderWorker::shutdown() {
    if (m_timer) m_timer->stop();
    closeMedia();
    if (m_mfInitialized) {
        MFShutdown();
        m_mfInitialized = false;
    }
    if (m_comInitialized) {
        CoUninitialize();
        m_comInitialized = false;
    }
}

void VideoDecoderWorker::closeMedia() {
    if (m_reader) {
        m_reader->Release();
        m_reader = nullptr;
    }
    m_videoWidth = 0;
    m_videoHeight = 0;
}

void VideoDecoderWorker::tick() {
    // Drop frames if the GUI hasn't consumed the previous one yet (never queue up).
    if (m_inFlight.load()) return;
    readNextFrame();
}

void VideoDecoderWorker::readNextFrame() {
    if (!m_reader) return;

    DWORD streamIndex = 0;
    DWORD flags = 0;
    LONGLONG timestamp = 0;
    IMFSample *pSample = nullptr;

    HRESULT hr = m_reader->ReadSample(
        static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM),
        0, &streamIndex, &flags, &timestamp, &pSample);

    if (flags & MF_SOURCE_READERF_ENDOFSTREAM) {
        // Rewind to start for a seamless loop
        PROPVARIANT var;
        PropVariantInit(&var);
        var.vt = VT_I8;
        var.hVal.QuadPart = 0;
        m_reader->SetCurrentPosition(GUID_NULL, var);
        PropVariantClear(&var);
        if (pSample) pSample->Release();
        m_inFlight.store(false);
        return;
    }

    if (FAILED(hr) || !pSample) {
        if (pSample) pSample->Release();
        m_inFlight.store(false);
        return;
    }

    if (m_videoWidth > 0 && m_videoHeight > 0) {
        IMFMediaBuffer *pBuffer = nullptr;
        if (SUCCEEDED(pSample->ConvertToContiguousBuffer(&pBuffer))) {
            BYTE *pData = nullptr;
            DWORD maxLength = 0, currentLength = 0;
            if (SUCCEEDED(pBuffer->Lock(&pData, &maxLength, &currentLength))) {
                const int srcStride = m_videoWidth * 4;
                if (m_videoWidth > 0 && m_videoHeight > 0 && pData) {
                    QImage frame(m_videoWidth, m_videoHeight, QImage::Format_RGB32);
                    const qsizetype dstStride = frame.bytesPerLine();
                    uchar *dst = frame.bits();
                    if (dstStride == srcStride) {
                        memcpy(dst, pData, static_cast<size_t>(m_videoHeight) * srcStride);
                    } else {
                        for (int y = 0; y < m_videoHeight; ++y)
                            memcpy(dst + y * dstStride, pData + y * srcStride, srcStride);
                    }
                    if (m_firstFrame.isNull()) {
                        m_firstFrame = frame;
                    }
                    m_inFlight.store(true);
                    emit frameReady(frame);
                }
                pBuffer->Unlock();
            }
            pBuffer->Release();
        }
    }
    pSample->Release();
}

// ═══════════════════════════════════════════════════════════════
// VideoBackgroundItem (GUI thread + GPU texture rendering)
// ═══════════════════════════════════════════════════════════════

VideoBackgroundItem::VideoBackgroundItem(QQuickItem *parent)
    : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);

    m_worker = new VideoDecoderWorker();
    m_worker->moveToThread(&m_thread);
    connect(m_worker, &VideoDecoderWorker::frameReady,
            this, &VideoBackgroundItem::onFrameReady, Qt::QueuedConnection);
    m_thread.setObjectName("VideoDecoder");
    m_thread.start();

    QMetaObject::invokeMethod(m_worker, "setPlaying", Qt::QueuedConnection, Q_ARG(bool, m_playing));
}

VideoBackgroundItem::~VideoBackgroundItem() {
    if (m_worker) {
        QMetaObject::invokeMethod(m_worker, "shutdown", Qt::BlockingQueuedConnection);
    }
    m_thread.quit();
    m_thread.wait();
    delete m_worker;
    m_worker = nullptr;
}

QString VideoBackgroundItem::resolvePath(const QString &source) const {
    QString resolved = source;
    if (resolved.startsWith("file:///")) {
        resolved = QUrl(resolved).toLocalFile();
    }
    if (QFileInfo::exists(resolved)) return resolved;

    const QDir appDir(QCoreApplication::applicationDirPath());
    const QString fileName = QFileInfo(resolved).fileName();
    const QStringList candidates = {
        appDir.filePath(source),
        appDir.filePath("assets/" + fileName),
        appDir.filePath("../assets/" + fileName)
    };
    for (const QString &c : candidates) {
        if (QFileInfo::exists(c)) return c;
    }
    return resolved;
}

void VideoBackgroundItem::setSource(const QString &source) {
    if (m_source == source) return;
    m_source = source;
    emit sourceChanged();

    const QString path = resolvePath(m_source);
    QMetaObject::invokeMethod(m_worker, "setPlaying", Qt::QueuedConnection, Q_ARG(bool, m_playing));
    // Blocking call on initial source load so frame #1 is already decoded before the window shows (no blank flash)
    if (m_frame.isNull()) {
        QMetaObject::invokeMethod(m_worker, "open", Qt::BlockingQueuedConnection,
                                  Q_ARG(QString, path), Q_ARG(int, m_targetFps));
        m_frame = m_worker->firstFrame();
        if (!m_frame.isNull()) {
            m_frameDirty = true;
            m_worker->markConsumed();
            update();
        }
    } else {
        QMetaObject::invokeMethod(m_worker, "open", Qt::QueuedConnection,
                                  Q_ARG(QString, path), Q_ARG(int, m_targetFps));
    }
}

void VideoBackgroundItem::setPlaying(bool play) {
    if (m_playing == play) return;
    m_playing = play;
    emit playingChanged();
    QMetaObject::invokeMethod(m_worker, "setPlaying", Qt::QueuedConnection, Q_ARG(bool, m_playing));
}

void VideoBackgroundItem::setTargetFps(int fps) {
    int clamped = qBound(10, fps, 60);
    if (m_targetFps == clamped) return;
    m_targetFps = clamped;
    emit targetFpsChanged();
    QMetaObject::invokeMethod(m_worker, "setTargetFps", Qt::QueuedConnection, Q_ARG(int, m_targetFps));
}

void VideoBackgroundItem::onFrameReady(const QImage &frame) {
    m_frame = frame;          // implicitly shared, no pixel copy
    m_frameDirty = true;
    if (m_worker) m_worker->markConsumed();
    update();
}

void VideoBackgroundItem::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) {
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.size() != oldGeometry.size()) update();
}

QSGNode *VideoBackgroundItem::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) {
    auto *node = static_cast<QSGImageNode *>(oldNode);
    const QRectF bounds = boundingRect();

    if (m_frame.isNull() || bounds.width() <= 0 || bounds.height() <= 0 || !window()) {
        delete node;
        return nullptr;
    }

    if (!node) {
        node = window()->createImageNode();
        node->setOwnsTexture(true);
        node->setFiltering(QSGTexture::Linear);
        // Prime with a dummy 1x1 texture so setTexture() never runs with a null initial state
        QImage dummy(1, 1, QImage::Format_RGB32);
        dummy.fill(QColor("#0a0d13"));
        node->setTexture(window()->createTextureFromImage(dummy));
        m_frameDirty = true;
    }

    if (m_frameDirty) {
        // Upload to GPU; scaling is done by the GPU, not the CPU.
        QSGTexture *texture = window()->createTextureFromImage(m_frame);
        node->setTexture(texture);   // node owns the texture and frees the previous one
        node->markDirty(QSGNode::DirtyMaterial);
        m_frameDirty = false;
    }

    // Aspect-fill: crop the source so it covers the whole item (like PreserveAspectCrop)
    const qreal iw = m_frame.width();
    const qreal ih = m_frame.height();
    const qreal itemAspect = bounds.width() / bounds.height();
    const qreal imgAspect = iw / ih;
    QRectF src;
    if (imgAspect > itemAspect) {
        const qreal sw = ih * itemAspect;
        src = QRectF((iw - sw) / 2.0, 0, sw, ih);
    } else {
        const qreal sh = iw / itemAspect;
        src = QRectF(0, (ih - sh) / 2.0, iw, sh);
    }

    node->setRect(bounds);
    node->setSourceRect(src);
    return node;
}
