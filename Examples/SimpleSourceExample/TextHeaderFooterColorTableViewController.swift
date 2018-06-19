import UIKit
import SimpleSource

/// This example shows how to add header and footer text to a `UITableView`.
final class TextHeaderFooterColorTableViewController: UITableViewController {
    private typealias DataSource = BasicDataSource<ColorSection>
    private typealias ViewFactory = TableViewFactory<ColorItem>
    
    private var tableViewDataSource: TableViewDataSource<DataSource, ViewFactory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func configureTableView() {
        let dataSource = DataSource(sections: ColorLoader.loadSections())
        let viewFactory = ViewFactory { _,_  in ColorTableCell.reuseIdentifier }
        
        viewFactory.registerCell(
            method: .dynamic,
            reuseIdentifier: ColorTableCell.reuseIdentifier,
            in: tableView,
            configuration: ColorTableCell.configureCell)
        
        viewFactory.registerHeaderText(in: tableView) { section in
            return dataSource.sections[section].title
        }

        viewFactory.registerFooterText(in: tableView) { section in
            let itemCount = dataSource.sections[section].items.count
            let itemString = (itemCount == 1) ? "item" : "items"
            return "\(itemCount) \(itemString)"
        }

        tableViewDataSource = TableViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: tableView.defaultViewUpdate())
        
        tableView.dataSource = tableViewDataSource
    }
}

