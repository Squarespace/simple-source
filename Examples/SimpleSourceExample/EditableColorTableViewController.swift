import UIKit
import SimpleSource

fileprivate let configureCell = { (cell: UITableViewCell, item: ColorItem, indexPath: IndexPath) -> Void in
    cell.backgroundColor = item.color
}

/// This example show how you can modify the data stored in a `BasicDataSource` and have
/// the table view respond with automatic animated updates.
///
/// Tap the + button in the toolbar to add a random color to the data source.
///
/// Tap a color cell to remove it from the data source.
final class EditableColorTableViewController: UITableViewController {
    private typealias DataSource = BasicDataSource<ColorSection>
    private typealias ViewFactory = TableViewFactory<ColorItem>
    
    // Just a bunch of colors to pick new items from.
    private var availableColors = ColorLoader.loadSections().flatMap { $0.items }
    
    // This is the data source which we will be modifying when the user taps items.
    private let dataSource = DataSource(sections: [ColorSection(title: "", items: [])])
    
    // The `UITableViewDataSource` object. We must retain it, since `UITableView` does not.
    private var tableViewDataSource: TableViewDataSource<DataSource, ViewFactory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func configureTableView() {
        let viewFactory = ViewFactory { _,_  in "Cell" }

        viewFactory.registerCell(
            method: .classBased(UITableViewCell.self),
            reuseIdentifier: "Cell",
            in: tableView,
            configuration: configureCell)
        
        tableViewDataSource = TableViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: tableView.defaultViewUpdate(with: .automatic))
        
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
    }

    // MARK: UI callbacks for adding and removing items
    
    @IBAction func addItem(_ sender: Any) {
        addRandomColor()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removeColor(at: indexPath)
    }
    
    // MARK: Manipulate the data source
    
    /// Append a random color to the data source. The table view will update automatically.
    private func addRandomColor() {
        guard !availableColors.isEmpty else { return }
        let randomIndex = Int(arc4random_uniform(UInt32(availableColors.count)))
        let randomColor = availableColors.remove(at: randomIndex)
        dataSource.sections[0].items.append(randomColor)
    }
    
    /// Remove a color from the data source. The table view will update automatically.
    private func removeColor(at indexPath: IndexPath) {
        let removedColor = dataSource.sections[indexPath.section].items.remove(at: indexPath.item)
        availableColors.append(removedColor)
    }
}
