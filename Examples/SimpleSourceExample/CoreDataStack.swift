import Foundation
import CoreData

/// A simple, in-memory Core Data stack which can load a list of fictional characters.
final class CoreDataStack {
    let managedObjectContext: NSManagedObjectContext
    
    init() {
        let modelURL = Bundle.main.url(forResource: "CharacterModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
    }
    
    func loadData() {
        CharacterLoader.load(into: managedObjectContext)
    }
    
    func fetchCharactersByRace() -> NSFetchedResultsController<Character> {
        let fetchRequest: NSFetchRequest<Character> = Character.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "race", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: "race",
            cacheName: nil)
    }
}
