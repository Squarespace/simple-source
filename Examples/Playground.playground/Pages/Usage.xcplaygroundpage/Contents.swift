import UIKit
import SimpleSource
import PlaygroundSupport

/*:
 - Important:
 Make sure to open this playground via `SimpleSourceExample.xcworkspace`. And remember to run `pod install` in the `Examples` directory to install the necessary prerequisites.
*/
/*:
 # SimpleSource Basic Usage

 The goal here is to show a bit of data in a table view using SimpleSource.
 */
/*:
 ## The Data
 
 We begin by defining our model object, which must conform to `Equatable`. In this case we'll just use `String`, but you can use anything `Equatable` for the items.
 */
typealias Item = String
/*:
 We want to organize our `Item` objects into sections. A section is anything conforming to the `SectionType` protocol.
 
 A section only has to provide an `items` array. But we are free to add more properties to a section, such as a title (or anything else we need) to properly configure section headers etc. 
 
 To illustrate this, let's also add a title to our custom section type, to make it a little richer.
 */
struct Section: SectionType {
    typealias ItemType = Item
    var title: String
    var items: [ItemType]
}
/*:  
 - Note:
 If you want automatic animated updates when your data mutates, your sections must also
 conform to `IdentifiableSection`. That way SimpleSource will be able to tell which sections have changed,
 and create the necessary animations for you when the data changes.

 Finally, let's create an array of `Section`s containing some `Item`s. This `[Section]` array will be our data.
 */
let sections: [Section] = [
    Section(title: "First Section", items: ["First item", "Second item"]),
    Section(title: "Second Section", items: ["First item in second section"])
]
/*: 
 We are ready to create the data source, which will hold the above data for use in SimpleSource.
 
 - Note:
 For explicit data (basic objects or values arranged in arrays), SimpleSource provides `BasicDataSource`. This is what we will use here. If your data is stored in Core Data you can use `CoreDataSource` instead.

 A `BasicDataSource` exposes a mutable `.sections` property. This can be set to a new value whenever you wish, triggering an update to all views backed by this data source.
 */
let dataSource = BasicDataSource(sections: sections)
/*:
 ## The Views
 
 Let's create a `UIViewController` with a `UITableView` to render our data:
 */
let vc = UITableViewController(style: .grouped)
/*:
 To get data into the `UITableView` we will need something which conforms to `UITableViewDataSource`: SimpleSource provides `TableViewDataSource` (to drive table views) and `CollectionViewDataSource` (to drive collection views).
 
 For our first example here let's create a `TableViewDataSource`.
 
 Looking at the initializer for `TableViewDataSource` we see that it needs three different things:
 
 - Some kind of data source from which to get the items
 - A view factory from which to get the cells
 - A way to incorporate changes in the data into the view

 We already have the data source from before, so the next step is to create a view factory. This will be responsible for emitting cells for the table.
 
 - Note:
 A view factory is initialized with a closure to provide a `reuseIdentifier` for a given item in a given view. Returning different values from this closure based on the item will allow you to mix different cell types in the same view. In our case we only have one cell type, so we only ever return one reuse identifier.
*/
let viewFactory = TableViewFactory<Item> { item, view in
    return "Cell"
}
/*: 
 With SimpleSource we use closures to configure cells as they are dequeued for display.
 
 The convenient thing about these closures is that they are given both a correctly typed cell and a correctly typed model object, which we then use to configure the cell.
 
 In this simple case we use vanilla `UITableViewCell`s, so that it what the closure gets. But if you have custom cell subclasses then that is what SimpleSource will send to your closure. No need for type casting.
 */
let configureCell = { (cell: UITableViewCell, item: Item, indexPath: IndexPath) -> Void in
    cell.textLabel?.text = item
}
/*: 
 Now we need to register the cell types we want to display with the view factory.
 
 This teaches the view factory how to dequeue the correct cells from the table view.
 
The `registerCell` method takes:

 - A cell instantiation method (you can use nibs, class-based or storyboard prototypes).
 - A reuse identifier.
 - The view to register the cell in.
 - The closure to configure the cell before display.
 
 - Note:
 If you want to mix multiple cells types in your table, there's two steps to it: In the closure passed to the `ViewFactory` initializer, you inspect the item and return the reuse identifier for the cell type you wish to display. Then call `registerCell` on the view factory for each possible reuse identifier that might be emitted from the above closure.
*/
viewFactory.registerCell(
    method: .classBased(UITableViewCell.self),
    reuseIdentifier: "Cell",
    in: vc.tableView,
    configuration: configureCell
)
/*:
 For good measure, let's also add some headers to show off the title properties of our sections.
 */
viewFactory.registerHeaderText(in: vc.tableView) { section in
    return dataSource.sections[section].title
}
/*:
 Now we are ready to create the `UITableViewDataSource` for our table view. This is going to be an instance of `TableViewDataSource`.
 
 We previously noted that `TableViewDataSource` needs you to provide a way to incorporate changes into the view. Most often you probably want to use one of the built-in row animations for table views, and use `performBatchUpdates` for collection views.
 
For table views SimpleSource defines `UITableView.defaultViewUpdate()` which does this animated update for you. If you prefer an unanimated update you can use `UITableView.unanimatedViewUpdate`. Or you can create your own. It's just a closure! You can also pass your favorite `UITableViewRowAnimation` to `defaultViewUpdate()` to customize it.
 
 For collection views the built-in view updaters are called `UICollectionView.defaultViewUpdate` and `UICollectionView.unanimatedViewUpdate`.
 
 Time to create the `TableViewDataSource`!
  */
let tableDataSource = TableViewDataSource(dataSource: dataSource, viewFactory: viewFactory, viewUpdate: vc.tableView.defaultViewUpdate())
/*:
 - Important: It is your responsibility to keep a reference to your `TableViewDataSource`. For example in an instance variable of the `UIViewController` using it. This is important because `UITableView` does not retain its `.dataSource` property. – If you want to, you can forget about the `BasicDataSource` and the `TableViewFactory` after you have created your `TableViewDataSource`. They will be retained for as long as they are needed.
 
 You are free to let one `BasicDataSource` back multiple `TableViewDataSource` or `CollectionViewDataSource` at the same time. All the views will automatically update if you change the data stored in `.sections` (or when the database changes if you are using `CoreDataSource`).
*/
/*:
## The Result
 
Now let's see the table view, rendering our data:
*/
vc.view.bounds.size = CGSize(width: 250, height: 300)
vc.tableView.dataSource = tableDataSource
PlaygroundPage.current.liveView = vc.view
/*: 
Press the play button to run this playground (if it's not already running) and open the timeline using Xcode's assistant editor to see the live table view, populated with our data.
 */
/*:
 ## What's Next?
 
 Run the example app in this workspace to see all this in action. Or dig into the documentation provided by the `README.md` file.
 */
