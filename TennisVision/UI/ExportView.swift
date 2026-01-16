import PhotosUI
import SwiftUI

struct ExportView: View {
    @ObservedObject var manager: SessionManager
    @State private var statusMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            if manager.isExporting {
                ProgressView("Exporting...")
            } else {
                Button("Export to Photos") {
                    Task {
                        await manager.exportCurrentProject()
                        await saveToPhotos()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if let error = manager.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Export")
    }

    private func saveToPhotos() async {
        guard let url = manager.currentProject?.exportedURL else { return }
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            statusMessage = "Photos permission not granted."
            return
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }
            statusMessage = "Saved to Photos."
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
