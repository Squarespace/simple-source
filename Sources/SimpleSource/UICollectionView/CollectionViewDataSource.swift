import UIKit

open class CollectionViewDataSource<DS, VF>: NSObject, UICollectionViewDataSource where DS: DataSourceType, VF: CollectionViewFactoryType, DS.Item == VF.Item {
    
    public typealias DataSource = DS
    public typealias ViewFactory = VF
    public typealias Item = DS.Item
    
    public let dataSource: DataSource
    public let viewFactory: ViewFactory

    // Used to temporarily ignore data source updates while reordering cells.
    private var ignoreDataSourceUpdates = false

    private var subscription: IndexedUpdateHandler.Subscription?
    
    public init(dataSource: DataSource, viewFactory: ViewFactory, viewUpdate: @escaping IndexedUpdateHandler.Observer) {
        self.dataSource = dataSource
        self.viewFactory = viewFactory

        super.init()

        self.subscription = dataSource.updateHandler.subscribe { [weak self] update in
            guard let `self` = self, !update.isEmpty, !self.ignoreDataSourceUpdates else { return }
            viewUpdate(update)
        }
    }
    
    public subscript(indexPath: IndexPath) -> Item? {
        return dataSource[indexPath]
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let item = dataSource[indexPath],
            let cell = viewFactory.cell(for: item, in: collectionView, at: indexPath)
        else {
            fatalError("Configuration error.")
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let supplementaryView = viewFactory.supplementaryView(ofKind: kind, in: collectionView, at: indexPath) else {
            fatalError("Configuration error.")
        }
        return supplementaryView
    }

    // MARK: Reordering

    public weak var reorderingDelegate: CollectionViewReorderingDelegate?

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let reorderingDelegate = self.reorderingDelegate else { return false }
        return reorderingDelegate.reordering(collectionView: collectionView, canMoveItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let reorderingDelegate = self.reorderingDelegate else { return }
        ignoreDataSourceUpdates = true
        reorderingDelegate.reordering(collectionView: collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
        ignoreDataSourceUpdates = false
    }
}
