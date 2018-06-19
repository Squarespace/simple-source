import Foundation
import SimpleSource

// MARK: Sections

struct ColorSection: SectionType {
    typealias Item = ColorItem
    let title: String
    var items: [Item]
}

extension ColorSection: IdentifiableSection {
    var sectionIdentifier: String { return title }
}

// MARK: Items

struct ColorItem: Equatable {
    let name: String
    let rgb: (CGFloat, CGFloat, CGFloat)
    
    var color: UIColor {
        return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
    }
}

func ==(lhs: ColorItem, rhs: ColorItem) -> Bool {
    return lhs.name == rhs.name && lhs.rgb == rhs.rgb
}

