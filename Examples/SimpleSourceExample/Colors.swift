import Foundation
import SimpleSource
import UIKit

// MARK: Sections

struct ColorSection: SectionType {
    typealias Item = ColorItem
    let title: String
    var items: [Item]
}

extension ColorSection: IdentifiableSection {
    var sectionIdentifier: String { return title }
}

extension ColorSection: Decodable {
    enum CodingKeys: String, CodingKey {
        case title
        case items = "colors"
    }
}

// MARK: Items

struct ColorItem {
    let name: String
    let rgb: (CGFloat, CGFloat, CGFloat)
    
    var color: UIColor {
        return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
    }
}

extension ColorItem: Equatable {
    static func == (lhs: ColorItem, rhs: ColorItem) -> Bool {
        lhs.name == rhs.name && lhs.rgb == rhs.rgb
    }
}

extension ColorItem: Decodable {
    enum Errors: Error {
        case rgbDecodingFailure
    }
    enum CodingKeys: String, CodingKey {
        case name
        case rgb
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let scanner = try Scanner(string: container.decode(String.self, forKey: .rgb))
        guard
            scanner.scanCharacters(from: .init(charactersIn: "#")) == "#",
            let rgbUInt64 = scanner.scanUInt64(representation: .hexadecimal)
        else {
            print("Name: \(name)\nRGBString: \(scanner.string)")
            throw Errors.rgbDecodingFailure
        }
        rgb = (
            CGFloat((rgbUInt64 & 0xff0000) >> 16) / 255,
            CGFloat((rgbUInt64 & 0x00ff00) >> 8)  / 255,
            CGFloat((rgbUInt64 & 0x0000ff) >> 0)  / 255
        )
    }
}
