import UIKit
import CoreData

class FetchDelegate: NSObject {
    
    private let updateHandler: IndexedUpdateHandler

    public init(updateHandler: IndexedUpdateHandler) {
        self.updateHandler = updateHandler
    }
    
    private struct PendingUpdates {
        var insertedSections = IndexSet()
        var updatedSections = IndexSet()
        var deletedSections = IndexSet()
        var insertedRows = Set<IndexPath>()
        var updatedRows = Set<IndexPath>()
        var deletedRows = Set<IndexPath>()
        
        func createUpdate() -> IndexedUpdate {
            let update: IndexedUpdate = .delta(
                insertedSections: insertedSections,
                updatedSections: updatedSections,
                deletedSections: deletedSections,
                insertedRows: Array(insertedRows),
                updatedRows: Array(updatedRows),
                deletedRows: Array(deletedRows)
            )
            return update
        }
    }
    
    private var pendingUpdates = PendingUpdates()
    
}

extension FetchDelegate: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch (type) {
        case NSFetchedResultsChangeType.delete:
            pendingUpdates.deletedSections.insert(sectionIndex)
        case NSFetchedResultsChangeType.insert:
            pendingUpdates.insertedSections.insert(sectionIndex)
        default:
            break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case NSFetchedResultsChangeType.insert:
            if indexPath == nil { // iOS 9 / Swift 2.0 BUG with running 8.4 (https://forums.developer.apple.com/thread/12184)
                if let newIndexPath = newIndexPath {
                    pendingUpdates.insertedRows.insert(newIndexPath)
                }
            }
        case NSFetchedResultsChangeType.delete:
            if let indexPath = indexPath {
                pendingUpdates.deletedRows.insert(indexPath)
            }
        case NSFetchedResultsChangeType.update:
            if let indexPath = indexPath {
                pendingUpdates.updatedRows.insert(indexPath)
            }
        case NSFetchedResultsChangeType.move:
            if
                let newIndexPath = newIndexPath,
                let indexPath = indexPath
            {
                pendingUpdates.insertedRows.insert(newIndexPath)
                pendingUpdates.deletedRows.insert(indexPath)
            }
        @unknown default:
            break
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let u = pendingUpdates.createUpdate()
        updateHandler.send(update: u)
        pendingUpdates = PendingUpdates()
    }
}

