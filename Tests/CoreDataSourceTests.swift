import Quick
import Nimble
import SimpleSource
import CoreData

private let StoreFilename = "SimpleSource-UnitTest-Store"

class CoreDataSourceTests: QuickSpec {
    
    lazy var model: NSManagedObjectModel = {
        let modelURL = Bundle(for: type(of: self)).url(forResource: "TestModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let fileManager = FileManager.default
        let directoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = directoryURL.appendingPathComponent("\(StoreFilename).sqlite")
        try? fileManager.removeItem(at: url)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        try? _ = coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        return coordinator
    }()
    
    lazy var context: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    lazy var fetchController: NSFetchedResultsController = { () -> NSFetchedResultsController<TestEntity> in
        let request: NSFetchRequest<TestEntity> = TestEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(TestEntity.name), ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: #keyPath(TestEntity.section), cacheName: nil)
        try? controller.performFetch()
        return controller
    }()
    
    override func spec() {
        describe("A CoreDataSource") {
            
            let dataSource = CoreDataSource(fetchedResultsController: fetchController)
            
            beforeEach {
                for object in self.fetchController.fetchedObjects ?? [] {
                    self.context.delete(object)
                }
                try? self.context.save()
            }
            
            describe("being empty") {
                it("doesn't crash when querying an empty store") {
                    let indexPath = IndexPath(item: 0, section: 0)
                    expect(dataSource.item(at: indexPath)).to(beNil())
                }
            }
            
            describe("having content") {
                var sections: [[TestEntity]]!
                
                beforeEach {
                    let entityA = self.createEntity(name: "a", section: 0)
                    let entityB = self.createEntity(name: "b", section: 1)
                    sections = [[entityA], [entityB]]
                    
                    try? self.context.save()
                }
                
                it("has the expected number of sections") {
                    expect(dataSource.numberOfSections()) == sections.count
                }
                
                it("has the expected number of items in each section") {
                    for sectionIndex in 0 ..< dataSource.numberOfSections() {
                        expect(dataSource.numberOfItems(in: sectionIndex)) == sections[sectionIndex].count
                    }
                }
                
                it("contains all the expected items via function lookup") {
                    for sectionIndex in 0 ..< dataSource.numberOfSections() {
                        for itemIndex in 0 ..< dataSource.numberOfItems(in: sectionIndex) {
                            let itemIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
                            expect(dataSource.item(at: itemIndexPath)) == sections[sectionIndex][itemIndex]
                        }
                    }
                }
                
                it("exposes the correct data via subscripting") {
                    for sectionIndex in 0 ..< dataSource.numberOfSections() {
                        for itemIndex in 0 ..< dataSource.numberOfItems(in: sectionIndex) {
                            let itemIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
                            expect(dataSource[itemIndexPath]) == dataSource.item(at: itemIndexPath)
                        }
                    }
                }
                
                it("can check if an index path is valid") {
                    let validIndexPaths = [
                        IndexPath(item: 0, section: 0),
                        IndexPath(item: 0, section: 1)
                    ]
                    
                    for indexPath in validIndexPaths {
                        expect(dataSource.contains(indexPath: indexPath)) == true
                    }
                    
                    let invalidIndexPaths = [
                        IndexPath(item: 3, section: 0),
                        IndexPath(item: 100, section: 0),
                        IndexPath(item: 0, section: 10),
                        IndexPath(item: 500, section: 5)
                    ]
                    
                    for indexPath in invalidIndexPaths {
                        expect(dataSource.contains(indexPath: indexPath)) == false
                    }
                }
                
                it("can iterate across all valid index paths") {
                    var collectedItems: [TestEntity] = []
                    for indexPath in dataSource.indexPathIterator() {
                        if let item = dataSource[indexPath] {
                            collectedItems.append(item)
                        }
                        expect(dataSource.contains(indexPath: indexPath)) == true
                    }
                    expect(collectedItems) == dataSource.allItems()
                }
            }
        }
    }
    
    private func createEntity(name: String, section: Int16) -> TestEntity {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "TestEntity", into: self.context) as! TestEntity
        entity.name = name
        entity.section = section
        return entity
    }
}
