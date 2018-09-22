import UIKit

/// Conform to this protocol to control editing of table view cells.
///
/// The two methods correspond to the similarly named ones in `UITableViewDataSource`.
///
/// Implementation note: We avoid using the exact same method names as in `UITableViewDataSource`.
/// Doing so will confuse the Swift compiler when using a `UITableViewController` as the
/// editing delegate, since it already conforms to `UITableViewDataSource`, but the method
/// implementations in Swift might not match the @objc requirements of that protocol.
///
/// Set the `editingDelegate` property of your `TableViewDataSource` to control editing.
public protocol TableViewEditingDelegate: class {
    func editing(tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    func editing(tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
}

extension TableViewEditingDelegate {
    /// Default implementation. An editing delegate can choose to omit this method in the common
    /// case where every item can be edited.
    public func editing(tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

