import CoreGraphics

struct Config {
    var frameSampleRate: Double
    var activityThreshold: Double
    var minKeepDuration: Double
    var mergeGap: Double
    var padStart: Double
    var padEnd: Double
    var analysisSize: CGSize

    static let defaultTraining = Config(
        frameSampleRate: 3,
        activityThreshold: 0.18,
        minKeepDuration: 4,
        mergeGap: 2,
        padStart: 1,
        padEnd: 1,
        analysisSize: CGSize(width: 224, height: 224)
    )

    static let defaultMatch = Config(
        frameSampleRate: 4,
        activityThreshold: 0.22,
        minKeepDuration: 5,
        mergeGap: 2,
        padStart: 1,
        padEnd: 1,
        analysisSize: CGSize(width: 224, height: 224)
    )
}
