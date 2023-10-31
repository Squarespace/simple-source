import UIKit

open class TableViewDataSource<DS, VF>: NSObject, UITableViewDataSource where DS: DataSourceType, VF: TableViewFactoryType, DS.Item == VF.Item {
    
    public typealias DataSource = DS
    public typealias ViewFactory = VF
    public typealias Item = DS.Item
    
    public let dataSource: DataSource
    public let viewFactory: ViewFactory

    // Used to temporarily ignore data source updates while reordering rows.
    private var ignoreDataSourceUpdates = false

    private var subscription: IndexedUpdateHandler.Subscription?

    public init(dataSource: DataSource, viewFactory: ViewFactory, viewUpdate: @escaping IndexedUpdateHandler.Observer) {
        self.dataSource = dataSource
        self.viewFactory = viewFactory

        super.init()

        self.subscription = dataSource.updateHandler.subscribe { [weak self] update in
            guard let `self` = self, !update.isEmpty, !self.ignoreDataSourceUpdates else { return }
            viewUpdate(update)
        }
    }
    
    public subscript(indexPath: IndexPath) -> Item? {
        return dataSource[indexPath]
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    // MARK: - Cells
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let item = dataSource[indexPath],
            let cell = viewFactory.cell(for: item, in: tableView, at: indexPath)
        else {
            fatalError("Configuration error.")
        }
        return cell
    }
    
    // MARK: - Headers and Footers
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewFactory.headerText(forSection: section, in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewFactory.footerText(forSection: section, in: tableView)
    }
    
    // NOTE: CUSTOM HEADER AND FOOTER VIEWS
    //
    // TableViewDataSource does not implement methods for custom header and footer views.
    //
    // That's because they are not the responsibility of a UITableViewDataSource. This is arguably
    // a design flaw in the UITableView API.
    //
    // If you use custom header and footer views you must implement these methods in your
    // UITableViewDelegate instead.
    //
    // SimpleSource can still assist you with dequeuing and configuring them! Just register them
    // with the TableViewFactory as normal. Then call the methods on the view factory from your 
    // UITableViewDelegate to retrieve properly dequeued and configured views.
    //
    // The TableViewFactory methods for this are:
    //
    //   func registerHeaderFooterView(method: _, reuseIdentifier: _, in: _, configuration: _)
    //   func headerFooterView(reuseIdentifier: _, in: _, forSection: _)

    // MARK: - Editing

    public weak var editingDelegate: TableViewEditingDelegate?

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return editingDelegate?.editing(tableView: tableView, canEditRowAt: indexPath) ?? false
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        editingDelegate?.editing(tableView: tableView, commit: editingStyle, forRowAt: indexPath)
    }

    // MARK: - Reordering

    public weak var reorderingDelegate: TableViewReorderingDelegate?

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let reorderingDelegate = self.reorderingDelegate else { return false }
        return reorderingDelegate.reordering(tableView: tableView, canMoveRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let reorderingDelegate = self.reorderingDelegate else { return }
        ignoreDataSourceUpdates = true
        reorderingDelegate.reordering(tableView: tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        ignoreDataSourceUpdates = false
    }
}
