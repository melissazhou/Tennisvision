import AVFoundation
import Combine
import Foundation

@MainActor
final class SessionManager: ObservableObject {
    @Published var currentProject: Project?
    @Published var analysisResult: AnalysisResult?
    @Published var isAnalyzing = false
    @Published var isExporting = false
    @Published var errorMessage: String?

    private let recorder = VideoRecorder()
    private let analyzer = Analyzer()
    private let composer = VideoComposer()
    private let store = ProjectStore()

    func startRecording() {
        errorMessage = nil
        recorder.start()
    }

    func stopRecording(title: String) async {
        errorMessage = nil
        do {
            let url = try await recorder.stop()
            let duration = try await VideoReader.videoDuration(url: url)
            let project = Project(
                title: title,
                originalURL: url,
                exportedURL: nil,
                durationSeconds: duration.seconds,
                segments: []
            )
            currentProject = project
            store.save(project: project)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func analyze(config: Config) async {
        guard let project = currentProject else { return }
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }

        do {
            let result = try await analyzer.analyze(videoURL: project.originalURL, config: config)
            analysisResult = result
            let segments = result.segments.map { segment in
                ProjectSegment(
                    startSeconds: segment.start.seconds,
                    endSeconds: segment.end.seconds,
                    confidence: segment.confidence,
                    keep: segment.keep
                )
            }
            currentProject?.segments = segments
            if let updated = currentProject {
                store.save(project: updated)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateSegments(_ segments: [ProjectSegment]) {
        currentProject?.segments = segments
        if let updated = currentProject {
            store.save(project: updated)
        }
    }

    func exportCurrentProject() async {
        guard let project = currentProject else { return }
        isExporting = true
        errorMessage = nil
        defer { isExporting = false }

        do {
            let segmentsToKeep = project.segments.filter { $0.keep }
            let outputURL = try await composer.compose(
                videoURL: project.originalURL,
                segmentsToKeep: segmentsToKeep
            )
            currentProject?.exportedURL = outputURL
            if let updated = currentProject {
                store.save(project: updated)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
