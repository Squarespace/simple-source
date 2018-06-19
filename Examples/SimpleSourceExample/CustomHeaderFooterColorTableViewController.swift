import UIKit
import SimpleSource

/// This example illustrates how to add custom header/footer views to a `UITableView`.
///
/// `TableViewDataSource` does not implement methods for creating custom header and footer views.
/// That's because they are not the responsibility of a `UITableViewDataSource`.
///
/// Header and footer text is part of the `UITableViewDataSource` protocol, but custom header/footer
/// views are instead part of the `UITableViewDelegate` protocol. This is arguably a flaw in the design
/// of the `UITableView` API.
///
/// SimpleSource only aims to be the data source. It does not want to be the delegate for your tables.
/// So if you use custom header and footer views you must implement these methods in your own
/// `UITableViewDelegate` instead.
///
/// But SimpleSource can still assist you with dequeuing and configuring them! Just register these views
/// with the `TableViewFactory` as normal. Then call the methods on the view factory from your
/// `UITableViewDelegate` to retrieve properly dequeued and configured views.
///
/// That is the approach shown in this example.
final class CustomHeaderFooterColorTableViewController: UITableViewController {
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

        // We use a custom class for the header here. That's usually what you want.
        // The configuration closure comes from the class itself.
        //
        // The configuration closure is given the dequeued header/footer view and 
        // the section number. If you need anything else to properly configure the
        // view you are free to capture it in the closure. Here we construct the
        // closure in a way that lets it capture the data source, so the section title
        // can be retrieved.
        viewFactory.registerHeaderFooterView(
            method: .classBased(ColorTableHeader.self),
            reuseIdentifier: "Header",
            in: tableView,
            configuration: ColorTableHeader.configureHeader(dataSource: dataSource))

        // Here we demonstrate a simpler solution for the footer, using a plain view. No nib or subclasses.
        // We configure it using a trailing closure, since that's also an option to us.
        viewFactory.registerHeaderFooterView(
            method: .classBased(UITableViewHeaderFooterView.self),
            reuseIdentifier: "Footer",
            in: tableView) { (footer: UITableViewHeaderFooterView, section: Int) in
            footer.textLabel?.text = "This is the footer in section \(section)."
        }
        
        tableViewDataSource = TableViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: tableView.defaultViewUpdate())
        
        tableView.dataSource = tableViewDataSource
    }

    // MARK: - UITableViewDelegate
    
    // Note how we have to implement `UITableViewDelegate`, but we can still use the view factory as a helper to 
    // create and configure the header and footer views below.
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewDataSource.viewFactory.headerFooterView(reuseIdentifier: "Header", in: tableView, forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableViewDataSource.viewFactory.headerFooterView(reuseIdentifier: "Footer", in: tableView, forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
}
