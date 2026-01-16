import Foundation

struct Project: Identifiable, Codable {
    let id: UUID
    var createdAt: Date
    var title: String
    var originalURL: URL
    var exportedURL: URL?
    var durationSeconds: Double
    var segments: [ProjectSegment]

    init(id: UUID = UUID(), createdAt: Date = Date(), title: String, originalURL: URL, exportedURL: URL?, durationSeconds: Double, segments: [ProjectSegment]) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.originalURL = originalURL
        self.exportedURL = exportedURL
        self.durationSeconds = durationSeconds
        self.segments = segments
    }
}

struct ProjectSegment: Identifiable, Codable, Hashable {
    let id: UUID
    var startSeconds: Double
    var endSeconds: Double
    var confidence: Float
    var keep: Bool

    init(id: UUID = UUID(), startSeconds: Double, endSeconds: Double, confidence: Float, keep: Bool) {
        self.id = id
        self.startSeconds = startSeconds
        self.endSeconds = endSeconds
        self.confidence = confidence
        self.keep = keep
    }
}
