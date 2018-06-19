import UIKit

/// Conform to this protocol to enable reordering of table view cells.
///
/// The two methods correspond to the similarly named ones in `UITableViewDataSource`.
///
/// Implementation note: We avoid using the exact same method names as in `UITableViewDataSource`.
/// Doing so will confuse the Swift compiler when using a `UITableViewController` as the
/// reordering delegate, since it already conforms to `UITableViewDataSource`, but the method
/// implementations in Swift might not match the @objc requirements of that protocol.
///
/// Set the `reorderingDelegate` property of your `TableViewDataSource` to enable reordering
/// in the data source.
public protocol TableViewReorderingDelegate: class {

    /// Return whether the item at the given index path can be moved or not.
    ///
    /// If you do not implement this method you will get a default implementation which returns `true`
    /// for every `IndexPath`.
    func reordering(tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool

    /// When an item is dropped into a new position, this method is called. In here you must make the change
    /// to the `DataSource` which backs the `TableViewDataSource`. Actually moving the item to the new
    /// index path.
    ///
    /// - If you are using a `BasicDataSource` you can use the method `moveItem(at:to:)`.
    ///
    /// - If you are using a `CoreDataSource` you must make whatever changes to your database needed
    ///   to make the item appear in the new place. This depends on the sort criteria of your
    ///   `NSFetchedResultsController`.
    ///
    /// - If you are using a custom `DataSource` you probably know what to do.
    ///
    /// Until this method returns, the `TableViewDataSource` will ignore updates from the `DataSource`
    /// that supplies its data. This is to avoid moving the items twice. Once by dragging and again when you
    /// modify the `DataSource`.
    ///
    /// This is why you must complete the modifications before execution returns from this method. Do not dispatch
    /// asynchronously or otherwise perform the changes in the background. If you do, the changes will be picked up by the
    /// `TableViewDataSource` and the items will be moved again. Breaking the internal book-keeping of your
    /// table view.
    func reordering(tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

extension TableViewReorderingDelegate {
    /// Default implementation. A reordering delegate can choose to omit this method in the common
    /// case where every row can be moved.
    public func reordering(tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
