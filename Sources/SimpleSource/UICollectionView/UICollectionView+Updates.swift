import UIKit

extension UICollectionView {
    public var unanimatedViewUpdate: IndexedUpdateHandler.Observer {
        return { [weak self] _ in self?.reloadData() }
    }
    
    public var defaultViewUpdate: IndexedUpdateHandler.Observer {
        return { [weak self] update in
            guard let self = self else { return }

            if self.window == nil || update.isLikelyToCrashUIKitViews {
                self.reloadData()
                return
            }

            switch update {
            case let .delta(insertedSections, updatedSections, deletedSections, insertedRows, updatedRows, deletedRows):
                self.performBatchUpdates({
                    self.insertSections(insertedSections)
                    self.deleteSections(deletedSections)
                    self.reloadSections(updatedSections)
                    self.insertItems(at: insertedRows)
                    self.deleteItems(at: deletedRows)
                    self.reloadItems(at: updatedRows)
                }, completion: { _ in })
            case .full:
                self.reloadData()
            }
        }
    }
}
