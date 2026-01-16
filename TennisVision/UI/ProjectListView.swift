import SwiftUI

struct ProjectListView: View {
    @StateObject private var manager = SessionManager()
    @State private var projects: [Project] = []
    private let store = ProjectStore()

    var body: some View {
        NavigationStack {
            List {
                Section("Projects") {
                    if projects.isEmpty {
                        Text("No sessions yet. Tap New Recording to start.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(projects) { project in
                        NavigationLink(destination: TimelineEditorView(project: project, manager: manager)) {
                            ProjectRow(project: project)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("TennisVision")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink("New Recording") {
                        RecordingView(manager: manager)
                    }
                }
            }
            .onAppear {
                projects = store.load()
                manager.currentProject = projects.first
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { projects[$0] }.forEach { store.delete(project: $0) }
        projects.remove(atOffsets: offsets)
    }
}

struct ProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.title)
                .font(.headline)
            Text(project.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Duration: \(project.durationSeconds, format: .number.precision(.fractionLength(1)))s")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
