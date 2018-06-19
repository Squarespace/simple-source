import UIKit

extension UITableView {
    public var unanimatedViewUpdate: IndexedUpdateHandler.Observer {
        return { [weak self] _ in self?.reloadData() }
    }
    
    public func defaultViewUpdate(with animation: UITableViewRowAnimation = .fade) -> IndexedUpdateHandler.Observer {
        return { [weak self] update in
            guard let _ = self?.window else {
                self?.reloadData()
                return
            }
            switch update {
            case .delta(let insertedSections, let updatedSections, let deletedSections, let insertedRows, let updatedRows, let deletedRows):
                self?.beginUpdates()
                self?.insertSections(insertedSections, with: animation)
                self?.deleteSections(deletedSections, with: animation)
                self?.reloadSections(updatedSections, with: animation)
                self?.insertRows(at: insertedRows, with: animation)
                self?.deleteRows(at: deletedRows, with: animation)
                self?.reloadRows(at: updatedRows, with: animation)
                self?.endUpdates()
            case .full:
                guard let `self` = self else { return }
                UIView.transition(with: self, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    self.reloadData()
                }, completion: nil)
            }
        }
    }
}
