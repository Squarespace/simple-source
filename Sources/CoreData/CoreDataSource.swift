import Foundation
import CoreData

public class CoreDataSource<Item>: DataSourceType where Item: NSManagedObject
{
    public let updateHandler = IndexedUpdateHandler()
    private lazy var fetchDelegate: FetchDelegate = FetchDelegate(updateHandler: self.updateHandler)
    
    public let fetchedResultsController: NSFetchedResultsController<Item>
    
    public init(fetchedResultsController: NSFetchedResultsController<Item>) {
        self.fetchedResultsController = fetchedResultsController
        self.fetchedResultsController.delegate = fetchDelegate
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print("Error fetching: \(error)")
        }
    }
    
    public func numberOfFetchedItems() -> Int {
        guard let fetched = fetchedResultsController.fetchedObjects else { return 0 }
        return fetched.count
    }
    
    public func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfItems(in sectionIndex: Int) -> Int {
        if let section = fetchedResultsController.sections?[sectionIndex] {
            return section.numberOfObjects
        }
        return 0
    }
    
    public func item(at indexPath: IndexPath) -> Item? {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects, !fetchedObjects.isEmpty else { return nil }
        return fetchedResultsController.object(at: indexPath)
    }
    
}
