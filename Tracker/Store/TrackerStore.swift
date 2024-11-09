import CoreData
import UIKit

class TrackerStore {
    static let shared = TrackerStore()
    private let context: NSManagedObjectContext

    private init() {
        self.context = AppDelegate.shared.persistentContainer.viewContext
    }

    func createTracker(id: UUID, name: String, emoji: String, color: UIColor, schedule: [WeekDay], categoryName: String, completion: @escaping (Tracker?) -> Void) {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = id
        trackerCoreData.name = name
        trackerCoreData.emoji = emoji
        trackerCoreData.color = color
        trackerCoreData.schedule = schedule as NSObject

        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        let categoryCoreData: TrackerCategoryCoreData
        if let existingCategory = try? context.fetch(categoryRequest).first {
            categoryCoreData = existingCategory
        } else {
            categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.name = categoryName
        }

        trackerCoreData.category = categoryCoreData
        categoryCoreData.addToTrackers(trackerCoreData)

        AppDelegate.shared.saveContext()

        let newTracker = Tracker(id: id, name: name, emoji: emoji, color: color, schedule: schedule)
        completion(newTracker)
    }

    func fetchTrackers(completion: @escaping ([Tracker]) -> Void) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let trackerEntities = try context.fetch(request)
            let trackers = trackerEntities.compactMap { entity -> Tracker? in
                guard let id = entity.id,
                      let name = entity.name,
                      let emoji = entity.emoji,
                      let color = entity.color as? UIColor,
                      let schedule = entity.schedule as? [WeekDay] else {
                    return nil
                }
                return Tracker(id: id, name: name, emoji: emoji, color: color, schedule: schedule)
            }
            completion(trackers)
        } catch {
            print("Не удалось получить трекеры: \(error)")
            completion([])
        }
    }
}
