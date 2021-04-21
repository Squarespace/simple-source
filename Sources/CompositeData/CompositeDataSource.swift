import Foundation

public class CompositeDataSource<A: DataSourceType, B: DataSourceType>: DataSourceType
{
    public var updateHandler = IndexedUpdateHandler()

    let firstDataSource: A
    let secondDataSource: B

    private var firstDataSourceSubscription: IndexedUpdateHandler.Subscription?
    private var secondDataSourceSubscription: IndexedUpdateHandler.Subscription?

    public init(firstDataSource: A, secondDataSource: B) {
        self.firstDataSource = firstDataSource
        self.secondDataSource = secondDataSource

        firstDataSourceSubscription = firstDataSource.updateHandler.subscribe { [weak self] update in
            guard let self = self else { return }
            print("firstDataSourceSubscription update: \(update)")
            self.updateHandler.send(update: update)
        }

        secondDataSourceSubscription = secondDataSource.updateHandler.subscribe { [weak self] update in
            guard let self = self else { return }
            print("secondDataSourceSubscription update: \(update)")
            let mappedUpdate = update.offsetSections(by: firstDataSource.numberOfSections())
            print("secondDataSourceSubscription update: \(mappedUpdate)")
            self.updateHandler.send(update: mappedUpdate)
        }
    }
}

public extension CompositeDataSource
{
    enum Item {
        case A(A.Item)
        case B(B.Item)
    }
}

extension CompositeDataSource.Item: Equatable where A.Item: Equatable, B.Item: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.A(lhsA), .A(rhsA)):
            return lhsA == rhsA
        case let (.B(lhsB), .B(rhsB)):
            return lhsB == rhsB
        default:
            return false
        }
    }
}

public extension CompositeDataSource {
    func numberOfSections() -> Int {
        firstDataSource.numberOfSections() + secondDataSource.numberOfSections()
    }

    func numberOfItems(in section: Int) -> Int {
        if sectionIsInFirstDataSource(section) {
            return firstDataSource.numberOfItems(in: section)
        } else {
            let mappedSection = section - firstDataSource.numberOfSections()
            return secondDataSource.numberOfItems(in: mappedSection)
        }
    }

    func item(at indexPath: IndexPath) -> Item? {
        if sectionIsInFirstDataSource(indexPath.section) {
            return firstDataSource.item(at: indexPath).map { Item.A($0) }
        } else {
            let mappedIndexPath = IndexPath(
                item: indexPath.item,
                section: indexPath.section - firstDataSource.numberOfSections()
            )
            return secondDataSource.item(at: mappedIndexPath).map { Item.B($0) }
        }
    }
}

private extension CompositeDataSource {
    func sectionIsInFirstDataSource(_ section: Int) -> Bool {
        return section < firstDataSource.numberOfSections()
    }
}

private extension IndexedUpdate {
    func offsetSections(by sectionOffset: Int) -> Self {
        switch self {
        case var .delta(
            insertedSections,
            updatedSections,
            deletedSections,
            insertedRows,
            updatedRows,
            deletedRows
        ):
            insertedSections = IndexSet(insertedSections.map { $0 + sectionOffset })
            updatedSections = IndexSet(updatedSections.map { $0 + sectionOffset })
            deletedSections = IndexSet(deletedSections.map { $0 + sectionOffset })
            insertedRows = insertedRows.map { IndexPath(item: $0.item, section: $0.section + sectionOffset) }
            updatedRows = updatedRows.map { IndexPath(item: $0.item, section: $0.section + sectionOffset) }
            deletedRows = deletedRows.map { IndexPath(item: $0.item, section: $0.section + sectionOffset) }

            return .delta(
                insertedSections: insertedSections,
                updatedSections: updatedSections,
                deletedSections: deletedSections,
                insertedRows: insertedRows,
                updatedRows: updatedRows,
                deletedRows: deletedRows
            )

        case .full:
            return self
        }
    }
}
