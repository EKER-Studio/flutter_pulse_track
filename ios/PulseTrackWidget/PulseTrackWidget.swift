import WidgetKit
import SwiftUI

struct PulseTrackProvider: TimelineProvider {
    func placeholder(in context: Context) -> PulseTrackEntry {
        PulseTrackEntry(date: Date(), hasData: true, lastWorkoutDate: "Today, 08:30", avgBpm: "142", maxBpm: "168", duration: "32m 15s", deviceName: "Polar H10", samplesCount: 120)
    }

    func getSnapshot(in context: Context, completion: @escaping (PulseTrackEntry) -> ()) {
        completion(getEntryFromUserDefaults())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntryFromUserDefaults()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getEntryFromUserDefaults() -> PulseTrackEntry {
        let suite = UserDefaults(suiteName: "group.com.ekerstudio.pulsetrack")
        let hasData = suite?.bool(forKey: "has_data") ?? false
        let date = suite?.string(forKey: "last_workout_date") ?? ""
        let avg = suite?.string(forKey: "avg_bpm") ?? "--"
        let max = suite?.string(forKey: "max_bpm") ?? "--"
        let duration = suite?.string(forKey: "duration") ?? "--"
        let device = suite?.string(forKey: "device_name") ?? ""
        let samples = suite?.integer(forKey: "samples_count") ?? 0
        return PulseTrackEntry(date: Date(), hasData: hasData, lastWorkoutDate: date, avgBpm: avg, maxBpm: max, duration: duration, deviceName: device, samplesCount: samples)
    }
}

struct PulseTrackEntry: TimelineEntry {
    let date: Date
    let hasData: Bool
    let lastWorkoutDate: String
    let avgBpm: String
    let maxBpm: String
    let duration: String
    let deviceName: String
    let samplesCount: Int
}

struct PulseTrackWidgetEntryView: View {
    var entry: PulseTrackEntry
    var body: some View {
        if !entry.hasData {
            VStack(spacing: 6) {
                Text("PulseTrack").font(.caption).bold().foregroundColor(.blue)
                Spacer()
                Text("No workouts yet").font(.subheadline)
                Spacer()
            }.padding()
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("PulseTrack").font(.caption2).foregroundColor(.secondary)
                Text(entry.lastWorkoutDate).font(.caption).foregroundColor(.secondary)
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(entry.avgBpm) BPM").font(.title2).bold()
                        Text("Avg").font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Max \(entry.maxBpm)").font(.caption)
                        Text(entry.duration).font(.caption2).foregroundColor(.secondary)
                    }
                }
                Text(entry.deviceName).font(.caption2).foregroundColor(.secondary).lineLimit(1)
            }.padding()
        }
    }
}

struct PulseTrackWidget: Widget {
    let kind: String = "PulseTrackWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PulseTrackProvider()) { entry in
            PulseTrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("PulseTrack")
        .description("Last workout summary")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
