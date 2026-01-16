import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Training Session"
    @State private var mode: Mode = .training
    @State private var isRecording = false
    @State private var showAnalysis = false
    @ObservedObject var manager: SessionManager

    enum Mode: String, CaseIterable, Identifiable {
        case training = "Training"
        case match = "Match"

        var id: String { rawValue }
        var config: Config {
            switch self {
            case .training: return .defaultTraining
            case .match: return .defaultMatch
            }
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Best camera position: behind baseline, above shoulder height, cover full court.")
                .font(.callout)
                .foregroundStyle(.secondary)

            TextField("Session title", text: $title)
                .textFieldStyle(.roundedBorder)

            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Button(isRecording ? "Stop Recording" : "Start Recording") {
                Task {
                    if isRecording {
                        await manager.stopRecording(title: title)
                        showAnalysis = true
                    } else {
                        manager.startRecording()
                    }
                    isRecording.toggle()
                }
            }
            .buttonStyle(.borderedProminent)

            if let error = manager.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .navigationTitle("New Recording")
        .navigationDestination(isPresented: $showAnalysis) {
            AnalysisProgressView(config: mode.config, manager: manager)
        }
        .onDisappear {
            if !isRecording {
                dismiss()
            }
        }
    }
}
