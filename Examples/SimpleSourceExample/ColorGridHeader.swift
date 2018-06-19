import UIKit
import SimpleSource

final class ColorGridHeader: UICollectionReusableView {
    @IBOutlet fileprivate weak var title: UILabel!
    
    static let reuseIdentifier = "ColorGridHeader"
    
    static func configureHeader(dataSource: BasicDataSource<ColorSection>) -> (ColorGridHeader, IndexPath) -> Void {
        return { (header, indexPath) in
            header.title.text = dataSource.sections[indexPath.section].title
        }
    }
}

