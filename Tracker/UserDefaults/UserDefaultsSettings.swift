import Foundation

protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterType)
}

final class UserDefaultsSettings {
    static let shared = UserDefaultsSettings()
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case onboardingWasShown
        case pinnedTrackers
        case currentFilterRawValue // Добавлено
    }
    
    private init() {}
    
    var onboardingWasShown: Bool {
        get {
            userDefaults.bool(forKey: Keys.onboardingWasShown.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.onboardingWasShown.rawValue)
        }
    }
    
    private(set) var pinnedTrackers: Set<UUID> = []
    
    func loadPinnedTrackers() {
        if let savedData = userDefaults.data(forKey: Keys.pinnedTrackers.rawValue),
           let savedIDs = try? JSONDecoder().decode(Set<UUID>.self, from: savedData) {
            pinnedTrackers = savedIDs
        } else {
            pinnedTrackers = []
        }
    }
    
    func savePinnedTrackers() {
        if let data = try? JSONEncoder().encode(pinnedTrackers) {
            userDefaults.set(data, forKey: Keys.pinnedTrackers.rawValue)
        }
    }
    
    func addPinnedTracker(id: UUID) {
        pinnedTrackers.insert(id)
        savePinnedTrackers()
    }
    
    func removePinnedTracker(id: UUID) {
        pinnedTrackers.remove(id)
        savePinnedTrackers()
    }
    
    func isPinned(trackerId: UUID) -> Bool {
        return pinnedTrackers.contains(trackerId)
    }
    
    // Добавлено: свойство для хранения текущего фильтра
    var currentFilterRawValue: Int {
        get {
            // Значение по умолчанию - .all
            return userDefaults.integer(forKey: Keys.currentFilterRawValue.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentFilterRawValue.rawValue)
        }
    }
}
