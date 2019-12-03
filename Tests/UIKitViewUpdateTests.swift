import UIKit
import Quick
import Nimble
@testable import SimpleSource

protocol DataSourceUpdateable: UIViewController {
    typealias Section = BasicIdentifiableSection<UIKitViewUpdateTests.Item>
    var dataSource: BasicDataSource<Section> { get }
    var onViewUpdate: ((IndexedUpdate) ->Void)? { get set }
    var viewNumberOfSections: Int { get }
    init(sections: [Section])
    func viewNumberOfRows(inSection: Int) -> Int
}

class UIKitViewUpdateTests: QuickSpec {
    typealias Section = BasicIdentifiableSection<Item>
    typealias DataSource = BasicDataSource<Section>

    static let cellIdentifier = "Cell"

    struct Item: Equatable, IdentifiableItem {
        let itemIdentifier: String
        var value: Bool
    }

    override func spec() {
        let vcTypes: [DataSourceUpdateable.Type] = [TableViewController.self, CollectionViewController.self]
        for type in vcTypes {

            describe("A \(type) with a data source") {

                var initialSections: [Section]!
                var vc: DataSourceUpdateable!
                var window: UIWindow!

                beforeEach {
                    initialSections = stride(from: 0, to: 3, by: 1).map { index -> Section in
                        let item = Item(itemIdentifier: "\(index)", value: true)
                        return Section(sectionIdentifier: "\(index)", items: [item])
                    }

                    vc = type.init(sections: initialSections)
                    window = UIWindow()
                    window.rootViewController = vc
                    vc.loadViewIfNeeded()
                    window.makeKeyAndVisible()
                }


                it("updates its view") {
                    expect(vc.viewNumberOfSections).toEventually(equal(initialSections.count))
                    expect(vc.viewNumberOfRows(inSection: 0)).toEventually(equal(initialSections[0].items.count))
                }

                it("performs a simple diff'ed update") {
                    var sections = initialSections!
                    sections[0].items[0].value.toggle()
                    sections[2].items[0].value.toggle()

                    var didPerformDiffedUpdate = false
                    var updateIsLikelyToCrashUITableView = true
                    vc.onViewUpdate = { update in
                        updateIsLikelyToCrashUITableView = update.isLikelyToCrashUIKitViews
                        switch update {
                        case .delta:
                            didPerformDiffedUpdate = true
                        case .full:
                            break
                        }
                    }

                    DispatchQueue.main.async {
                        vc.dataSource.sections = sections
                    }

                    expect(updateIsLikelyToCrashUITableView).toEventually(equal(false))
                    expect(didPerformDiffedUpdate).toEventually(equal(true))
                }

                it("survives a complex update") {
                    // Move all items from section 1 to section 0 and delete section 1
                    var sections = initialSections!
                    sections[0].items.append(contentsOf: sections[1].items)
                    sections.remove(at: 1)

                    // Change the value of the first item in the (previous section 2 but now) section 1
                    sections[1].items[0].value.toggle()

                    var updateIsLikelyToCrashUITableView = false
                    vc.onViewUpdate = { update in
                        updateIsLikelyToCrashUITableView = update.isLikelyToCrashUIKitViews
                    }

                    DispatchQueue.main.async {
                        vc.dataSource.sections = sections
                    }

                    expect(updateIsLikelyToCrashUITableView).toEventually(equal(true))
                    expect(vc.viewNumberOfSections).toEventually(equal(sections.count))
                }
            }
        }
    }
}

extension UIKitViewUpdateTests {
    fileprivate final class TableViewController: UITableViewController, DataSourceUpdateable {
        typealias ViewDataSource = TableViewDataSource<DataSource, TableViewFactory<Item>>
        typealias Cell = UITableViewCell

        let sections: [Section]

        var onViewUpdate: ((IndexedUpdate) ->Void)?

        lazy var viewDataSource: ViewDataSource = {
            let dataSource = DataSource(sections: self.sections)
            let viewFactory = TableViewFactory<Item> { _,_ in UIKitViewUpdateTests.cellIdentifier }
            let configuration: (Cell, Item, IndexPath) -> Void = { (_, _, _) in }
            viewFactory.registerCell(
                method: .classBased(Cell.self),
                reuseIdentifier: UIKitViewUpdateTests.cellIdentifier,
                in: tableView,
                configuration: configuration
            )
            let defaultViewUpdate = tableView.defaultViewUpdate()
            let viewUpdate: IndexedUpdateHandler.Observer = { [weak self] update in
                self?.onViewUpdate?(update)
                defaultViewUpdate(update)
            }
            return ViewDataSource(
                dataSource: dataSource,
                viewFactory: viewFactory,
                viewUpdate: viewUpdate
            )
        }()

        var dataSource: BasicDataSource<BasicIdentifiableSection<Item>> {
            return viewDataSource.dataSource
        }

        var viewNumberOfSections: Int { return tableView!.numberOfSections }

        func viewNumberOfRows(inSection: Int) -> Int {
            return tableView.numberOfRows(inSection: inSection)
        }

        init(sections: [Section]) {
            self.sections = sections
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = viewDataSource
        }
    }

    fileprivate final class CollectionViewController: UICollectionViewController, DataSourceUpdateable {
        typealias ViewDataSource = CollectionViewDataSource<DataSource, CollectionViewFactory<Item>>
        typealias Cell = UICollectionViewCell

        let sections: [Section]

        var onViewUpdate: ((IndexedUpdate) ->Void)?

        lazy var viewDataSource: ViewDataSource = {
            let dataSource = DataSource(sections: self.sections)
            let viewFactory = CollectionViewFactory<Item> { _,_ in UIKitViewUpdateTests.cellIdentifier }
            let configuration: (Cell, Item, IndexPath) -> Void = { (_, _, _) in }
            viewFactory.registerCell(
                method: .classBased(Cell.self),
                reuseIdentifier: UIKitViewUpdateTests.cellIdentifier,
                in: collectionView,
                configuration: configuration
            )
            let defaultViewUpdate = collectionView.defaultViewUpdate
            let viewUpdate: IndexedUpdateHandler.Observer = { [weak self] update in
                self?.onViewUpdate?(update)
                defaultViewUpdate(update)
            }
            return ViewDataSource(
                dataSource: dataSource,
                viewFactory: viewFactory,
                viewUpdate: viewUpdate
            )
        }()

        var dataSource: BasicDataSource<BasicIdentifiableSection<Item>> {
            return viewDataSource.dataSource
        }

        var viewNumberOfSections: Int { return collectionView!.numberOfSections }

        func viewNumberOfRows(inSection: Int) -> Int {
            return collectionView.numberOfItems(inSection: inSection)
        }

        init(sections: [Section]) {
            self.sections = sections
            super.init(collectionViewLayout: UICollectionViewFlowLayout())
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            collectionView.dataSource = viewDataSource
        }
    }
}
