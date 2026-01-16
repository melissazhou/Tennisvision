import AVFoundation
import CoreImage

enum VideoReader {
    static func videoDuration(url: URL) async throws -> CMTime {
        let asset = AVAsset(url: url)
        return try await asset.load(.duration)
    }

    static func readSampledFrames(url: URL, sampleRate: Double, targetSize: CGSize) async throws -> [CGImage] {
        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = targetSize

        let totalSeconds = duration.seconds
        let step = 1.0 / sampleRate
        var times: [NSValue] = []
        var current = 0.0
        while current < totalSeconds {
            let time = CMTime(seconds: current, preferredTimescale: 600)
            times.append(NSValue(time: time))
            current += step
        }

        var images: [CGImage] = []
        for time in times {
            let cgImage = try generator.copyCGImage(at: time.timeValue, actualTime: nil)
            images.append(cgImage)
        }
        return images
    }
}
