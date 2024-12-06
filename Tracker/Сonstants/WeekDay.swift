import Foundation

enum WeekDay: Codable, Hashable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    case specificDate(Date)
    
    var displayName: String {
        switch self {
        case .sunday:
            return NSLocalizedString("sunday", comment: "")
        case .monday:
            return NSLocalizedString("monday", comment: "")
        case .tuesday:
            return NSLocalizedString("tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("thursday", comment: "")
        case .friday:
            return NSLocalizedString("friday", comment: "")
        case .saturday:
            return NSLocalizedString("saturday", comment: "")
        case .specificDate(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    var shortDisplayName: String {
        switch self {
        case .sunday:
            return NSLocalizedString("short_sunday", comment: "")
        case .monday:
            return NSLocalizedString("short_monday", comment: "")
        case .tuesday:
            return NSLocalizedString("short_tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("short_wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("short_thursday", comment: "")
        case .friday:
            return NSLocalizedString("short_friday", comment: "")
        case .saturday:
            return NSLocalizedString("short_saturday", comment: "")
        case .specificDate(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    var weekdayIndex: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .specificDate:
            return Int.max
        }
    }
    
    static func from(date: Date) -> WeekDay {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        switch weekdayNumber {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: fatalError("Invalid weekday number")
        }
    }
}

extension WeekDay: CaseIterable {
    static var allCases: [WeekDay] {
        return [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
}
