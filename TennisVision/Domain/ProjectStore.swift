import Foundation

struct ProjectStore {
    private let folderName = "Projects"
    private let metadataFile = "projects.json"

    private var storeURL: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(folderName)
    }

    private var metadataURL: URL {
        storeURL.appendingPathComponent(metadataFile)
    }

    func load() -> [Project] {
        guard let data = try? Data(contentsOf: metadataURL) else { return [] }
        return (try? JSONDecoder().decode([Project].self, from: data)) ?? []
    }

    func save(project: Project) {
        var projects = load()
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        } else {
            projects.append(project)
        }
        persist(projects)
    }

    func delete(project: Project) {
        var projects = load()
        projects.removeAll { $0.id == project.id }
        persist(projects)
        try? FileManager.default.removeItem(at: project.originalURL)
        if let exported = project.exportedURL {
            try? FileManager.default.removeItem(at: exported)
        }
    }

    func ensureStoreExists() {
        guard !FileManager.default.fileExists(atPath: storeURL.path) else { return }
        try? FileManager.default.createDirectory(at: storeURL, withIntermediateDirectories: true)
    }

    func newRecordingURL() -> URL {
        ensureStoreExists()
        return storeURL.appendingPathComponent("recording-\(UUID().uuidString).mov")
    }

    func newExportURL() -> URL {
        ensureStoreExists()
        return storeURL.appendingPathComponent("export-\(UUID().uuidString).mov")
    }

    private func persist(_ projects: [Project]) {
        ensureStoreExists()
        if let data = try? JSONEncoder().encode(projects) {
            try? data.write(to: metadataURL)
        }
    }
}
