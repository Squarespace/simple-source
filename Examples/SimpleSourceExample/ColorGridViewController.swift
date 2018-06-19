import UIKit
import SimpleSource

/// This example show how to populate a simple collection view.
///
/// This is very similar to `ColorTableViewController`, except we use the
/// `UICollectionView`-specific classes here:
///
///    - `CollectionViewFactory`
///    - `CollectionViewDataSource`
///
/// instead of `TableViewFactory` and `TableViewDataSource`.
///
/// The underlying data source is exactly the same as for the table view example.
/// It is still a `BasicDataSource`, which knows nothing about the view that will eventually
/// display its data.
final class ColorGridViewController: UICollectionViewController {
    private typealias DataSource = BasicDataSource<ColorSection>
    private typealias ViewFactory = CollectionViewFactory<ColorItem>
    
    private var collectionViewDataSource: CollectionViewDataSource<DataSource, ViewFactory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
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
        
        collectionView.dataSource = collectionViewDataSource
    }

}
