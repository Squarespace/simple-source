import UIKit
import SimpleSource

/// This example shows how to add custom headers to a `UICollectionView`.
///
/// For simplicity we use a standard `UICollectionViewFlowLayout` and add headers. 
/// But this approach can also be used to support supplementary view for any custom 
/// `UICollectionViewLayout` you may have.
///
/// Just use your own custom `kind` values defined by the layout when you call
/// `registerSupplementaryView` on the view factory.
final class HeaderColorGridViewController: UICollectionViewController {
    private typealias DataSource = BasicDataSource<ColorSection>
    private typealias ViewFactory = CollectionViewFactory<ColorItem>
    
    private var collectionViewDataSource: CollectionViewDataSource<DataSource, ViewFactory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        guard let collectionView = self.collectionView else { return }

        // Let our custom headers pin to the top when scrolling.
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
        
        let reuseIdentifier = "Cell"
        let dataSource = DataSource(sections: ColorLoader.loadSections())
        let viewFactory = ViewFactory { _,_  in reuseIdentifier }
        
        // Here we use a trailing closure to configure the cells. Just to try something different.
        // We don't even bother with a custom cell class, and the reuse identifier could be anything,
        // as long as it matches the value returned from the closure given to ViewFactory above.
        viewFactory.registerCell(
            method: .classBased(UICollectionViewCell.self),
            reuseIdentifier: reuseIdentifier,
            in: collectionView) { (cell: UICollectionViewCell, item: ColorItem, indexPath: IndexPath) in
            cell.contentView.backgroundColor = item.color
            cell.contentView.layer.cornerRadius = 6
        }
        
        // UICollectionViewFlowLayout uses UICollectionElementKindSectionHeader for the supplementary view kind.
        //
        // Note that the configuration closure for a supplementary view does not get an item passed in.
        //
        // The reason is that an item may not exist in the data source for the index path. One example could be 
        // headers for empty sections. The header has an index path, but no item exists for that index path.
        //
        // Some supplementary views need the item. E.g. title labels under cells. Others (like section headers
        // and footers) need to access section information which is only available through the data source.
        // And some might not even need the data source because the views are independant of the data.
        //
        // In our case we need access to the section title, so we construct the closure using the data source.
        // You are free to construct configuration closures that capture whatever you need to set up the
        // supplementary views.
        let configureHeader = ColorGridHeader.configureHeader(dataSource: dataSource)
        viewFactory.registerSupplementaryView(
            method: .dynamic,
            kind: UICollectionElementKindSectionHeader,
            reuseIdentifier: ColorGridHeader.reuseIdentifier,
            in: collectionView,
            configuration: configureHeader)
        
        collectionViewDataSource = CollectionViewDataSource(
            dataSource: dataSource,
            viewFactory: viewFactory,
            viewUpdate: collectionView.defaultViewUpdate)

        collectionView.dataSource = collectionViewDataSource
    }
    
}
