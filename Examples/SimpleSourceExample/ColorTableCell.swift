import UIKit

final class ColorTableCell: UITableViewCell {
    @IBOutlet fileprivate weak var name: UILabel!
    @IBOutlet fileprivate weak var swatch: UIView!
    
    static let reuseIdentifier = "ColorTableCell"
    
    static let configureCell = { (cell: ColorTableCell, item: ColorItem, indexPath: IndexPath) in
        cell.name.text = item.name
        cell.swatch.backgroundColor = item.color
    }
}
