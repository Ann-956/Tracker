import UIKit 

enum TrackerDataType: Int, CaseIterable {
    case category
    case schedule
    
    var displayName: String {
        switch self {
        case .category:
            return NSLocalizedString("category_name", comment: "")
        case .schedule:
            return NSLocalizedString("schedule_name", comment: "")
        }
    }
}
