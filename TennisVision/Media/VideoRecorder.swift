import AVFoundation
import Foundation

final class VideoRecorder: NSObject {
    private let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let queue = DispatchQueue(label: "VideoRecorder.session")
    private var continuation: CheckedContinuation<URL, Error>?
    private var outputURL: URL?
    private let store = ProjectStore()

    func start() {
        queue.async {
            self.configureSessionIfNeeded()
            self.session.startRunning()
            let url = self.store.newRecordingURL()
            self.outputURL = url
            self.movieOutput.startRecording(to: url, recordingDelegate: self)
        }
    }

    func stop() async throws -> URL {
        guard movieOutput.isRecording else {
            throw RecorderError.notRecording
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.movieOutput.stopRecording()
        }
    }

    private func configureSessionIfNeeded() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let audioDevice = AVCaptureDevice.default(for: .audio) else {
            session.commitConfiguration()
            return
        }

        if let videoInput = try? AVCaptureDeviceInput(device: videoDevice), session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        if let audioInput = try? AVCaptureDeviceInput(device: audioDevice), session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }

        session.commitConfiguration()
    }
}

extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        session.stopRunning()
        if let error {
            continuation?.resume(throwing: error)
            return
        }
        continuation?.resume(returning: outputFileURL)
    }
}

enum RecorderError: LocalizedError {
    case notRecording

    var errorDescription: String? {
        switch self {
        case .notRecording:
            return "Recording is not active."
        }
    }
}
