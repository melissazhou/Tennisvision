import AVFoundation

final class VideoComposer {
    private let store = ProjectStore()

    func compose(videoURL: URL, segmentsToKeep: [ProjectSegment]) async throws -> URL {
        let asset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()
        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw ComposerError.missingVideoTrack
        }

        let audioTrack = try await asset.loadTracks(withMediaType: .audio).first
        let compositionVideo = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAudio = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var cursor = CMTime.zero
        for segment in segmentsToKeep {
            let start = CMTime(seconds: segment.startSeconds, preferredTimescale: 600)
            let end = CMTime(seconds: segment.endSeconds, preferredTimescale: 600)
            let timeRange = CMTimeRange(start: start, end: end)

            try compositionVideo?.insertTimeRange(timeRange, of: videoTrack, at: cursor)
            if let audioTrack {
                try compositionAudio?.insertTimeRange(timeRange, of: audioTrack, at: cursor)
            }
            cursor = CMTimeAdd(cursor, timeRange.duration)
        }

        let outputURL = store.newExportURL()
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw ComposerError.exportFailed
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = false

        try await exporter.export()
        if exporter.status != .completed {
            throw exporter.error ?? ComposerError.exportFailed
        }
        return outputURL
    }
}

enum ComposerError: LocalizedError {
    case missingVideoTrack
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .missingVideoTrack:
            return "Missing video track in asset."
        case .exportFailed:
            return "Video export failed."
        }
    }
}
