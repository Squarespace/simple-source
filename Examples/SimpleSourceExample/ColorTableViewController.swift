import UIKit
import SimpleSource

/// This is the most basic example.
///
/// It shows a list of colors, with no headers/footers and no interactions.
///
/// The static data comes from a `BasicDataSource`.
final class ColorTableViewController: UITableViewController {
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
        
        tableViewDataSource = TableViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: tableView.defaultViewUpdate())
        
        tableView.dataSource = tableViewDataSource
    }
}

