import CoreData

final class TrackerRecordStore {
    static let shared = TrackerRecordStore()
    private let context: NSManagedObjectContext

    private init() {
        self.context = AppDelegate.shared.persistentContainer.viewContext
    }

    func addRecord(trackerId: UUID, date: Date, completion: @escaping (Bool) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, startOfDay as NSDate, endOfDay as NSDate)
        
        context.perform {
            do {
                let existingRecords = try self.context.fetch(request)
                if existingRecords.isEmpty {
                    let recordCoreData = TrackerRecordCoreData(context: self.context)
                    recordCoreData.trackerId = trackerId
                    recordCoreData.date = startOfDay
                    try self.context.save()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("TrackerRecordDidChange"), object: nil)
                        completion(true)
                    }
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            } catch {
                print("Не удалось добавить запись: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }
    }


    func deleteRecord(trackerId: UUID, date: Date, completion: @escaping (Bool) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, startOfDay as NSDate, endOfDay as NSDate)
        
        context.perform {
            do {
                let records = try self.context.fetch(request)
                for record in records {
                    self.context.delete(record)
                }
                try self.context.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("TrackerRecordDidChange"), object: nil)
                    completion(true)
                }
            } catch {
                print("Не удалось удалить запись: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    func fetchRecords(completion: @escaping ([TrackerRecord]) -> Void) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        context.perform {
            do {
                let recordEntities = try self.context.fetch(request)
                let records = recordEntities.compactMap { entity -> TrackerRecord? in
                    guard let trackerId = entity.trackerId, let date = entity.date else { return nil }
                    return TrackerRecord(trackerId: trackerId, date: date)
                }
                DispatchQueue.main.async { completion(records) }
            } catch {
                print("Не удалось получить записи: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
}
