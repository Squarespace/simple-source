import UIKit
import SimpleSource

/// This example shows how to reorder cells in a collection view.
///
/// Setting a `reorderingDelegate` on the `CollectionViewDataSource` indicates that
/// reordering is supported. Implementing this delegate for a `BasicDataSource` is a
/// simple one-liner.
///
/// In this example we rely on the reordering gestures automatically installed by
/// `UICollectionViewController` (see the documentation for `installsStandardGestureForInteractiveMovement`). 
///
/// If you're not using `UICollectionViewController` you can install your own gestures and
/// call the relevant reordering methods on the collection view as touches are processed.
/// But that's not specific to SimpleSource. There is an example of how to do this at
/// http://nshint.io/blog/2015/07/16/uicollectionviews-now-have-easy-reordering/
final class ReorderingColorGridViewController: UICollectionViewController {
    fileprivate typealias DataSource = BasicDataSource<ColorSection>
    fileprivate typealias ViewFactory = CollectionViewFactory<ColorItem>

    fileprivate var collectionViewDataSource: CollectionViewDataSource<DataSource, ViewFactory>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    fileprivate func configureCollectionView() {
        guard let collectionView = self.collectionView else { return }

        let dataSource = DataSource(sections: ColorLoader.loadSections())
        let viewFactory = ViewFactory { _,_  in ColorGridCell.reuseIdentifier }

        viewFactory.registerCell(
            method: .dynamic,
            reuseIdentifier: ColorGridCell.reuseIdentifier,
            in: collectionView,
            configuration: ColorGridCell.configureCell)

        collectionViewDataSource = CollectionViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: collectionView.defaultViewUpdate)

        collectionViewDataSource.reorderingDelegate = self

        collectionView.dataSource = collectionViewDataSource
    }

}

// The `BasicDataSource` knows how to move items around, so this implementation is easy.
//
// If you use a `CoreDataSource` you need to modify your managed objects in a way that makes the
// item move as specified in the `NSFetchedResultsController`, and then save the context. This
// depends on your Core Data models and their sort criteria.
//
// Any changes must be made synchronously, before you return from this method. Otherwise the
// change to the data source will be picked up as a normal modification and sent to the `viewUpdate`
// which will try to update the collection view (which is already updated by the reordering).
extension ReorderingColorGridViewController: CollectionViewReorderingDelegate {
    func reordering(collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        collectionViewDataSource.dataSource.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
}
