import UIKit
import SimpleSource

final class ColorTableHeader: UITableViewHeaderFooterView {
    private var titleLabel: UILabel!
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black
        titleLabel.autoresizingMask = [.flexibleHeight , .flexibleWidth]
        titleLabel.translatesAutoresizingMaskIntoConstraints = true
        
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = UIColor(white: 0.8, alpha: 1)
    }
    
    static func configureHeader(dataSource: BasicDataSource<ColorSection>) -> (ColorTableHeader, Int) -> Void {
        return { (header, section) in
            header.titleLabel.text = dataSource.sections[section].title
        }
    }
}
