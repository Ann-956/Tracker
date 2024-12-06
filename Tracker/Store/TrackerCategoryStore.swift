import CoreData
import UIKit

final class TrackerCategoryStore  {
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext
    
    private init() {
        self.context = AppDelegate.shared.persistentContainer.viewContext
    }
    
    func createCategory(name: String, completion: @escaping (TrackerCategory?) -> Void) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let existingCategories = try context.fetch(request)
            if !existingCategories.isEmpty {
                completion(nil)
                return
            }
        } catch {
            completion(nil)
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.name = name
        
        AppDelegate.shared.saveContext()
        
        let newCategory = TrackerCategory(name: name, trackers: [])
        completion(newCategory)
    }
    
    func fetchCategories(completion: @escaping ([TrackerCategory]) -> Void) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let categoryEntities = try context.fetch(request)
            
            let categories = categoryEntities.compactMap { entity -> TrackerCategory? in
                guard let name = entity.name else {
                    
                    return nil
                }
                
                let trackersSet = entity.trackers as? Set<TrackerCoreData> ?? []
                let trackerModels = trackersSet.compactMap { trackerEntity in
                    Tracker(id: trackerEntity.id ?? UUID(),
                            name: trackerEntity.name ?? "",
                            emoji: trackerEntity.emoji ?? "",
                            color: trackerEntity.color as? UIColor ?? UIColor.black,
                            schedule: trackerEntity.schedule as? [WeekDay] ?? [])
                }
                return TrackerCategory(name: name, trackers: trackerModels)
            }
            completion(categories)
        } catch {
            completion([])
        }
    }
}

