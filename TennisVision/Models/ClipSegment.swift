import AVFoundation

struct ClipSegment: Identifiable, Codable, Hashable {
    let id: UUID
    var start: CMTime
    var end: CMTime
    var confidence: Float
    var keep: Bool

    init(start: CMTime, end: CMTime, confidence: Float, keep: Bool) {
        self.id = UUID()
        self.start = start
        self.end = end
        self.confidence = confidence
        self.keep = keep
    }

    var duration: CMTime {
        CMTimeSubtract(end, start)
    }
}

extension ClipSegment {
    struct CodableTime: Codable {
        let seconds: Double

        init(_ time: CMTime) {
            self.seconds = time.seconds
        }

        var time: CMTime {
            CMTime(seconds: seconds, preferredTimescale: 600)
        }
    }
}
