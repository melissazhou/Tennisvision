import AVKit
import SwiftUI

struct TimelineEditorView: View {
    @State var project: Project
    @ObservedObject var manager: SessionManager
    @State private var segments: [ProjectSegment] = []

    var body: some View {
        VStack(spacing: 16) {
            VideoPlayer(player: AVPlayer(url: project.originalURL))
                .frame(height: 220)
                .cornerRadius(12)

            List {
                Section("Segments") {
                    ForEach($segments) { $segment in
                        SegmentRow(segment: $segment)
                    }
                }
            }
            .listStyle(.insetGrouped)

            NavigationLink("Export", destination: ExportView(manager: manager))
                .buttonStyle(.borderedProminent)
        }
        .onAppear {
            segments = project.segments
        }
        .onChange(of: segments) { newSegments in
            manager.updateSegments(newSegments)
        }
        .navigationTitle("Timeline")
    }
}

struct SegmentRow: View {
    @Binding var segment: ProjectSegment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Keep segment", isOn: $segment.keep)
            Text("\(segment.startSeconds, format: .number.precision(.fractionLength(1)))s - \(segment.endSeconds, format: .number.precision(.fractionLength(1)))s")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                Text("Start trim")
                    .font(.caption)
                Slider(value: $segment.startSeconds, in: max(0, segment.startSeconds - 2)...segment.endSeconds)
            }
            VStack(alignment: .leading) {
                Text("End trim")
                    .font(.caption)
                Slider(value: $segment.endSeconds, in: segment.startSeconds...segment.endSeconds + 2)
            }
        }
    }
}
