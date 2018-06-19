import UIKit
import SimpleSource

/// This example shows how to drive a table view using Core Data.
///
/// This is very similar to using static/explicit data arrays. Just replace
/// `BasicDataSource` with `CoreDataSource`.
///
/// A `CoreDataSource` is initialized with an `NSFetchedResultsController`, which will
/// continually update the connected views if changes are made to the database.
final class CharacterTableViewController: UITableViewController {
    private typealias DataSource = CoreDataSource<Character>
    private typealias ViewFactory = TableViewFactory<Character>

    private var coreDataStack: CoreDataStack!
    private var tableViewDataSource: TableViewDataSource<DataSource, ViewFactory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load some data. Normally this would not live in your view controller.
        coreDataStack = CoreDataStack()
        coreDataStack.loadData()
        
        configureTableView()
    }
    
    private func configureTableView() {
        // The data source needs an `NSFetchedResultsController` when you create it. 
        // This is how you define what data to show and how to sort and section it.
        let dataSource = CoreDataSource(fetchedResultsController: coreDataStack.fetchCharactersByRace())
        let viewFactory = ViewFactory { _,_  in "Cell" }

        // Here we use the built-in `UITableViewCellStyle` for our cells.
        viewFactory.registerCell(method: .style(.default), reuseIdentifier: "Cell", in: tableView) { (cell: UITableViewCell, character: Character, indexPath: IndexPath) in
            cell.textLabel?.text = character.name
        }
        
        // Show the section name in the headers.
        viewFactory.registerHeaderText(in: tableView) { section in
            return dataSource.fetchedResultsController.sections?[section].name
        }
        
        tableViewDataSource = TableViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: tableView.defaultViewUpdate())
        
        tableView.dataSource = tableViewDataSource
    }
}

