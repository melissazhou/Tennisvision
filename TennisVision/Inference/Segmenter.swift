import AVFoundation

struct Segmenter {
    func segments(from scores: [Double], config: Config, fps: Double, duration: CMTime) -> [ClipSegment] {
        guard !scores.isEmpty else { return [] }
        let paddedScores = smooth(scores: scores, windowSize: Int(fps))
        let threshold = config.activityThreshold

        var rawSegments: [(start: Double, end: Double)] = []
        var startIndex: Int?

        for (index, score) in paddedScores.enumerated() {
            if score >= threshold, startIndex == nil {
                startIndex = index
            } else if score < threshold, let startIndex {
                let startTime = Double(startIndex) / fps
                let endTime = Double(index) / fps
                rawSegments.append((start: startTime, end: endTime))
                self.startIndexReset(&startIndex)
            }
        }

        if let startIndex {
            let startTime = Double(startIndex) / fps
            let endTime = duration.seconds
            rawSegments.append((start: startTime, end: endTime))
        }

        let merged = merge(segments: rawSegments, gap: config.mergeGap)
        let filtered = merged.filter { $0.end - $0.start >= config.minKeepDuration }

        return filtered.map { segment in
            let paddedStart = max(0, segment.start - config.padStart)
            let paddedEnd = min(duration.seconds, segment.end + config.padEnd)
            return ClipSegment(
                start: CMTime(seconds: paddedStart, preferredTimescale: 600),
                end: CMTime(seconds: paddedEnd, preferredTimescale: 600),
                confidence: Float(min(1.0, (segment.end - segment.start) / 10.0)),
                keep: true
            )
        }
    }

    private func smooth(scores: [Double], windowSize: Int) -> [Double] {
        guard windowSize > 1 else { return scores }
        var smoothed: [Double] = []
        for index in scores.indices {
            let start = max(0, index - windowSize)
            let end = min(scores.count - 1, index + windowSize)
            let slice = scores[start...end]
            let average = slice.reduce(0, +) / Double(slice.count)
            smoothed.append(average)
        }
        return smoothed
    }

    private func merge(segments: [(start: Double, end: Double)], gap: Double) -> [(start: Double, end: Double)] {
        guard var current = segments.first else { return [] }
        var merged: [(start: Double, end: Double)] = []

        for segment in segments.dropFirst() {
            if segment.start - current.end <= gap {
                current.end = segment.end
            } else {
                merged.append(current)
                current = segment
            }
        }
        merged.append(current)
        return merged
    }

    private func startIndexReset(_ startIndex: inout Int?) {
        startIndex = nil
    }
}
