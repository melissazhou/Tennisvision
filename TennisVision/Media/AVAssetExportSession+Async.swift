import AVFoundation

extension AVAssetExportSession {
    func export() async throws {
        try await withCheckedThrowingContinuation { continuation in
            exportAsynchronously {
                switch self.status {
                case .completed:
                    continuation.resume()
                case .failed, .cancelled:
                    continuation.resume(throwing: self.error ?? ExportError.failed)
                default:
                    continuation.resume(throwing: ExportError.unknown)
                }
            }
        }
    }
}

enum ExportError: LocalizedError {
    case failed
    case unknown

    var errorDescription: String? {
        switch self {
        case .failed:
            return "Export failed."
        case .unknown:
            return "Export finished with unknown status."
        }
    }
}
