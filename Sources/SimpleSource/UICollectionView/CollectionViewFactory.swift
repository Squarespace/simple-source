import UIKit

public enum CollectionViewRegistrationMethod {
    case classBased(AnyClass?)
    case nibBased(UINib?)
    case dynamic
}

public protocol CollectionViewFactoryType {
    associatedtype Item
    
    func registerCell<C>(method: CollectionViewRegistrationMethod, reuseIdentifier: String, in view: UICollectionView, configuration: @escaping (_ cell: C, _ item: Item, _ indexPath: IndexPath) -> Void)
    func cell(for item: Item, in view: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell?
    
    func registerSupplementaryView<S>(method: CollectionViewRegistrationMethod, kind: String, reuseIdentifier: String, in view: UICollectionView, configuration: @escaping (_ supplementaryView: S, _ indexPath: IndexPath) -> Void)
    func supplementaryView(ofKind kind: String, in view: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView?
}

public class CollectionViewFactory<Item>: CollectionViewFactoryType {
    
    // These just make our internal types more readable.
    private typealias ContainerView = UICollectionView
    private typealias ReuseIdentifier = String
    private typealias SupplementaryViewKind = String
    private typealias ContainerViewIdentifier = Int
    private typealias CellProvider = (Item, ContainerView, IndexPath) -> Any?
    private typealias SupplementaryViewProvider = (ContainerView, IndexPath) -> Any?
    
    private let reuseIdentifierForItem: (Item, ContainerView) -> String
    private var cellProviders = [ContainerViewIdentifier : [ReuseIdentifier : CellProvider]]()
    private var supplementaryViewProviders = [ContainerViewIdentifier : [SupplementaryViewKind : SupplementaryViewProvider]]()
    
    public init(reuseIdentifierForItem: @escaping (Item, UICollectionView) -> String) {
        self.reuseIdentifierForItem = reuseIdentifierForItem
    }

    // MARK: - Cells
    
    public func registerCell<C>(method: CollectionViewRegistrationMethod, reuseIdentifier: String, in view: UICollectionView, configuration: @escaping (_ cell: C, _ item: Item, _ indexPath: IndexPath) -> Void) {
        switch method {
        case .classBased(let c):
            view.register(c, forCellWithReuseIdentifier: reuseIdentifier)
        case .nibBased(let nib):
            view.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        case .dynamic:
            break
        }
        
        var cellProvidersForView = cellProviders[view.hashValue] ?? [:]
        cellProvidersForView[reuseIdentifier] = { (item, view, indexPath) -> C? in
            guard let cell = view.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? C else { return nil }
            configuration(cell, item, indexPath)
            return cell
        }
        cellProviders[view.hashValue] = cellProvidersForView
    }
    
    public func cell(for item: Item, in view: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell? {
        let reuseIdentifier = reuseIdentifierForItem(item, view)
        let cellProvider = cellProviders[view.hashValue]?[reuseIdentifier]
        return cellProvider?(item, view, indexPath) as? UICollectionViewCell
    }
    
    // MARK: - Supplementary Views
    
    public func registerSupplementaryView<S>(method: CollectionViewRegistrationMethod, kind: String, reuseIdentifier: String, in view: UICollectionView, configuration: @escaping (_ supplementaryView: S, _ indexPath: IndexPath) -> Void) {
        switch method {
        case .classBased(let c):
            view.register(c, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        case .nibBased(let nib):
            view.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
        case .dynamic:
            break
        }
        
        var supplementaryViewProvidersForView = supplementaryViewProviders[view.hashValue] ?? [:]
        supplementaryViewProvidersForView[kind] = { (view, indexPath) -> S? in
            guard let supplementaryView = view.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as? S else { return nil }
            configuration(supplementaryView, indexPath)
            return supplementaryView
        }
        supplementaryViewProviders[view.hashValue] = supplementaryViewProvidersForView
    }
    
    public func supplementaryView(ofKind kind: String, in view: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView? {
        let supplementaryViewProvider = supplementaryViewProviders[view.hashValue]?[kind]
        return supplementaryViewProvider?(view, indexPath) as? UICollectionReusableView
    }
}
