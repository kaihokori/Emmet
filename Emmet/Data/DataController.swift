import CoreData
import CloudKit

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Database")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No Descriptions Found")
        }
        
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.dev.kylegraham.emmet")
        description.cloudKitContainerOptions?.databaseScope = .public

        container.loadPersistentStores { desc, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                do {
                    try self.container.initializeCloudKitSchema(options: [])
                } catch {
                    print("Error initializing CloudKit schema: \(error)")
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        cleanupDeletedEvents()
    }
    
    func cleanupDeletedEvents() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()

        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -30, to: Date())!
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isMarkedForDeletion == YES"),
            NSPredicate(format: "date < %@", cutoffDate as NSDate)
        ])

        do {
            let eventsToDelete = try context.fetch(fetchRequest)
            for event in eventsToDelete {
                context.delete(event)
            }
            try context.save()
        } catch {
            print("Error cleaning up deleted events: \(error)")
        }
    }
}
