import SwiftUI

struct AnalysisProgressView: View {
    let config: Config
    @ObservedObject var manager: SessionManager

    var body: some View {
        VStack(spacing: 16) {
            ProgressView("Analyzing...", value: manager.isAnalyzing ? 0.6 : 1.0)
                .progressViewStyle(.linear)
            Text("Analyzing offline. This can take a few minutes on long sessions.")
                .font(.callout)
                .foregroundStyle(.secondary)

            if manager.isAnalyzing {
                Button("Cancel") {
                    manager.isAnalyzing = false
                }
                .buttonStyle(.bordered)
            } else {
                NavigationLink("Review Timeline") {
                    if let project = manager.currentProject {
                        TimelineEditorView(project: project, manager: manager)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task {
            await manager.analyze(config: config)
        }
        .navigationTitle("Analysis")
    }
}
