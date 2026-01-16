import AVFoundation

final class Analyzer {
    private let detector = ActivityDetector()
    private let segmenter = Segmenter()

    func analyze(videoURL: URL, config: Config) async throws -> AnalysisResult {
        let frames = try await VideoReader.readSampledFrames(
            url: videoURL,
            sampleRate: config.frameSampleRate,
            targetSize: config.analysisSize
        )
        let scores = detector.scoreActivity(frames: frames)
        let duration = try await VideoReader.videoDuration(url: videoURL)
        let segments = segmenter.segments(
            from: scores,
            config: config,
            fps: config.frameSampleRate,
            duration: duration
        )
        return AnalysisResult(segments: segments, videoDuration: duration)
    }
}
