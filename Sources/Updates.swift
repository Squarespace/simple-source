import UIKit

public enum IndexedUpdate {
    case delta(
        insertedSections: IndexSet,
        updatedSections: IndexSet,
        deletedSections: IndexSet,
        insertedRows: [IndexPath],
        updatedRows: [IndexPath],
        deletedRows: [IndexPath]
    )
    case full
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
    
    func send(update: IndexedUpdate) {
        observers.values.forEach { $0(update) }
    }
}
