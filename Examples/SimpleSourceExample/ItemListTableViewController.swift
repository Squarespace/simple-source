import UIKit
import SimpleSource

// MARK: - ListItem

private struct ListItem {
    let uuid: String
    let name: String

    init(name: String) {
        self.uuid = UUID().uuidString
        self.name = name
    }
}

extension ListItem: IdentifiableItem {
    var itemIdentifier: String {
        return uuid
    }
}

extension ListItem: Equatable {
    static func ==(lhs: ListItem, rhs: ListItem) -> Bool {
        return (lhs.uuid == rhs.uuid) && (lhs.name == rhs.name)
    }
}

// MARK: - View Controller

fileprivate let configureCell = { (cell: UITableViewCell, item: ListItem, indexPath: IndexPath) -> Void in
    cell.textLabel?.text = item.name
}

final class ItemListTableViewController: UITableViewController {
    private typealias Section = BasicIdentifiableSection<ListItem>
    private typealias DataSource = BasicDataSource<Section>
    private typealias ViewFactory = TableViewFactory<ListItem>

    private var itemCounter = 0
    private let dataSource = DataSource(sections: [Section(sectionIdentifier: "The only section", items: [])])

    // The `UITableViewDataSource` object. We must retain it, since `UITableView` does not.
    private var tableViewDataSource: TableViewDataSource<DataSource, ViewFactory>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    // MARK: Table View

    private func configureTableView() {
        let viewFactory = ViewFactory { _,_  in "Cell" }

        viewFactory.registerCell(
            method: .style(.default),
            reuseIdentifier: "Cell",
            in: tableView,
            configuration: configureCell)

        tableViewDataSource = TableViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: tableView.defaultViewUpdate(with: .automatic))

        // Hook into the data source to handle editing and reordering.
        tableViewDataSource.editingDelegate = self
        tableViewDataSource.reorderingDelegate = self

        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
    }

    // Prevent regular cell selection.
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // This method is part of UITableViewDelegate, so it will not be provided or proxied by the SimpleSource data source.
    // SimpleSource only implements methods from UITableViewDataSource.
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // MARK: Navigation bar buttons

    @IBAction func addItem(_ sender: Any) {
        let newItem = ListItem(name: "Item \(itemCounter)")
        dataSource.sections[0].items.append(newItem)
        itemCounter += 1
    }

    @IBAction func toggleEditMode(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
}

// MARK: Editing

extension ItemListTableViewController: TableViewEditingDelegate {
    func editing(tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataSource.sections[0].items.remove(at: indexPath.item)
    }
}

// MARK: Reordering

extension ItemListTableViewController: TableViewReorderingDelegate {
    func reordering(tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dataSource.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
}
