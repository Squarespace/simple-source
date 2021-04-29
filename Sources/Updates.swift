import UIKit

public enum IndexedUpdate: Equatable {
    case delta(
        insertedSections: IndexSet,
        updatedSections: IndexSet,
        deletedSections: IndexSet,
        insertedRows: [IndexPath],
        updatedRows: [IndexPath],
        deletedRows: [IndexPath]
    )
    case full

    /// Whether the update is considered empty.
    ///
    /// - `true` for delta updates with no content
    /// - `false` in all other cases
    public var isEmpty: Bool {
        switch self {
        case let .delta(insertedSections, updatedSections, deletedSections, insertedRows, updatedRows, deletedRows):
            return insertedSections.isEmpty &&
                updatedSections.isEmpty &&
                deletedSections.isEmpty &&
                insertedRows.isEmpty &&
                updatedRows.isEmpty &&
                deletedRows.isEmpty
        case .full:
            return false
        }
    }

    var isLikelyToCrashUIKitViews: Bool {
        switch self {
        case let .delta(insertedSections, updatedSections, deletedSections, insertedRows, updatedRows, deletedRows):
            let hasItemUpdates = !(insertedRows.isEmpty && updatedRows.isEmpty && deletedRows.isEmpty)
            let hasSectionUpdates = !(insertedSections.isEmpty && updatedSections.isEmpty && deletedSections.isEmpty)
            return hasItemUpdates && hasSectionUpdates
        case .full:
            return false
        }
    }
}

public class IndexedUpdateHandler {
    
    public typealias Observer = ((IndexedUpdate) -> ())

    // An opaque object, representing a subscription to updates.
    public class Subscription {
        private let onDeinit: () -> Void

        fileprivate init(onDeinit: @escaping () -> Void) {
            self.onDeinit = onDeinit
        }
        
        deinit {
            onDeinit()
        }
    }
    
    private typealias Token = String
    private var observers = [Token : Observer]()

    public init() {}
    
    deinit {
        observers.removeAll()
    }
    
    // Returns an opaque Subscription object, which must be retained for as long as the Observer
    // wants to receive updates. Release the Subscription object to deregister the Observer.
    public func subscribe(_ observer: @escaping Observer) -> Subscription {
        let token = NSUUID().uuidString
        observers[token] = observer
        return Subscription { [weak self] in
            self?.observers.removeValue(forKey: token)
        }
    }
    
    public func sendFullUpdate() {
        send(update: .full)
    }
    
    public func send(update: IndexedUpdate) {
        observers.values.forEach { $0(update) }
    }
}

public extension IndexedUpdate {
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

    static func createDelta(
        insertedSections: IndexSet = .init(),
        updatedSections: IndexSet = .init(),
        deletedSections: IndexSet = .init(),
        insertedRows: [IndexPath] = [],
        updatedRows: [IndexPath] = [],
        deletedRows: [IndexPath] = []
    ) -> Self {
        .delta(
            insertedSections:insertedSections,
            updatedSections:updatedSections,
            deletedSections:deletedSections,
            insertedRows: insertedRows,
            updatedRows: updatedRows,
            deletedRows: deletedRows
        )
    }
}
