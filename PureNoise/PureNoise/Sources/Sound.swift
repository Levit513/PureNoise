import Foundation

struct Sound: Identifiable, Hashable {
    let id: String
    let name: String
    let systemImage: String
    let filename: String
    let isFree: Bool
}

enum SoundCatalog {
    static let freeCount = 8

    static let sounds: [Sound] = {
        let items: [(String, String, String)] = [
            ("Rain", "cloud.rain.fill", "rain"),
            ("Brown Noise", "waveform", "brown_noise"),
            ("Pink Noise", "waveform", "pink_noise"),
            ("White Noise", "waveform", "white_noise"),
            ("Ocean", "water.waves", "ocean"),
            ("Fan", "fan.fill", "fan"),
            ("Fireplace", "flame.fill", "fireplace"),
            ("Wind", "wind", "wind"),
            ("Forest Night", "leaf.fill", "forest_night"),
            ("Crickets", "dot.radiowaves.left.and.right", "crickets"),
            ("Airplane Cabin", "airplane", "airplane"),
            ("Train", "tram.fill", "train"),
            ("Cafe", "cup.and.saucer.fill", "cafe"),
            ("Babbling Brook", "drop.fill", "brook"),
            ("Waterfall", "drop.triangle.fill", "waterfall"),
            ("Keyboard (Soft)", "keyboard.fill", "keyboard_soft"),
            ("City Night", "building.2.fill", "city_night"),
            ("Space Hum", "sparkles", "space_hum"),
            ("AC Hum", "snowflake", "ac_hum"),
            ("Heater", "heater.vertical", "heater"),
            ("Shower", "shower.fill", "shower"),
            ("Snow", "snow", "snow"),
            ("Waves (Calm)", "water.waves", "waves_calm"),
            ("Waves (Stormy)", "tornado", "waves_stormy"),
            ("Leaves", "leaf", "leaves"),
            ("Distant Storm", "cloud.bolt.rain.fill", "distant_storm"),
            ("Night Drive", "car.fill", "night_drive"),
            ("Meditation Drone", "circle.dotted", "drone"),
            ("Deep Focus", "brain.head.profile", "deep_focus"),
            ("Thunder (Soft)", "cloud.bolt.fill", "thunder_soft")
        ]

        return items.enumerated().map { idx, item in
            Sound(
                id: item.2,
                name: item.0,
                systemImage: item.1,
                filename: item.2,
                isFree: idx < freeCount
            )
        }
    }()
}
