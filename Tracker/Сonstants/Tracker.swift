import Foundation

// Модель трекера
struct Tracker {
    let id: UUID
    let name: String
    let emoji: String
    let color: String
    let schedule: [WeekDay] // дни недели, когда трекер активен
}

// Категория трекеров
struct TrackerCategory {
    let name: String
    var trackers: [Tracker]
}

// Запись о выполнении трекера
struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
}

// Дни недели
enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
