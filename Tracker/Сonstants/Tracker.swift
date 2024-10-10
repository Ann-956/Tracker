import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let emoji: String
    let color: String
    let schedule: [WeekDay]
}

struct TrackerCategory {
    let name: String
    var trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
}

enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
