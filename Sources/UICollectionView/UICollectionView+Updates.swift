import UIKit

extension UICollectionView {
    public var unanimatedViewUpdate: IndexedUpdateHandler.Observer {
        return { [weak self] _ in self?.reloadData() }
    }
    
    public var defaultViewUpdate: IndexedUpdateHandler.Observer {
        return { [weak self] update in
            guard let _ = self?.window else {
                self?.reloadData()
                return
            }
            self?.performBatchUpdates({
                switch update {
                case let .delta(insertedSections, updatedSections, deletedSections, insertedRows, updatedRows, deletedRows):
                    guard let strongSelf = self else { return }
                    strongSelf.insertSections(insertedSections)
                    strongSelf.deleteSections(deletedSections)
                    strongSelf.reloadSections(updatedSections)
                    strongSelf.insertItems(at: insertedRows)
                    strongSelf.deleteItems(at: deletedRows)
                    strongSelf.reloadItems(at: updatedRows)
                case .full:
                    self?.reloadData()
                }
            }, completion: { _ in })
        }
    }
}
