import CoreGraphics
import CoreImage

struct ActivityDetector {
    func scoreActivity(frames: [CGImage]) -> [Double] {
        guard frames.count > 1 else { return [] }

        var scores: [Double] = []
        var previous = frames[0]

        for index in 1..<frames.count {
            let current = frames[index]
            let diff = frameDifference(lhs: previous, rhs: current)
            scores.append(diff)
            previous = current
        }
        return scores
    }

    private func frameDifference(lhs: CGImage, rhs: CGImage) -> Double {
        let ciContext = CIContext(options: [.workingColorSpace: NSNull()])
        let lhsImage = CIImage(cgImage: lhs)
        let rhsImage = CIImage(cgImage: rhs)
        let diffFilter = CIFilter(name: "CIDifferenceBlendMode")
        diffFilter?.setValue(lhsImage, forKey: kCIInputImageKey)
        diffFilter?.setValue(rhsImage, forKey: kCIInputBackgroundImageKey)

        guard let output = diffFilter?.outputImage else { return 0 }
        let extent = output.extent
        guard let outputCG = ciContext.createCGImage(output, from: extent) else { return 0 }
        return averageLuma(image: outputCG)
    }

    private func averageLuma(image: CGImage) -> Double {
        guard let dataProvider = image.dataProvider,
              let data = dataProvider.data else { return 0 }
        let ptr = CFDataGetBytePtr(data)
        let length = CFDataGetLength(data)
        guard let ptr else { return 0 }

        var sum: Double = 0
        for i in stride(from: 0, to: length, by: 4) {
            let r = Double(ptr[i])
            let g = Double(ptr[i + 1])
            let b = Double(ptr[i + 2])
            sum += (0.2126 * r + 0.7152 * g + 0.0722 * b)
        }

        let pixelCount = Double(length / 4)
        return pixelCount == 0 ? 0 : (sum / pixelCount) / 255.0
    }
}
