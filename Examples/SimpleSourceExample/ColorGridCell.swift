import UIKit

final class ColorGridCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var swatch: UIView!

    static let reuseIdentifier = "ColorGridCell"
    
    static let configureCell = { (cell: ColorGridCell, item: ColorItem, indexPath: IndexPath) in
        cell.swatch.backgroundColor = item.color
    }
}
