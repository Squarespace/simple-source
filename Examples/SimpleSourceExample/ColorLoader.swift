import Foundation
import SwiftyJSON

struct ColorLoader {
    
    /// Loads colors (organized into sections) from a JSON file.
    static func loadSections() -> [ColorSection] {
        let dataURL = Bundle.main.url(forResource: "colors", withExtension: "json")!
        let data = try! Data(contentsOf: dataURL)
        return try! JSON(data: data).arrayValue.compactMap(parseSection)
    }
    
    // MARK: Private
    
    private static func parseSection(json: JSON) -> ColorSection? {
        guard
            let title = json["title"].string,
            let colors = json["colors"].array
        else { return nil }
        
        return ColorSection(title: title, items: colors.compactMap(parseItem))
    }
    
    private static func parseItem(json: JSON) -> ColorItem? {
        guard
            let name = json["name"].string,
            let rgbString = json["rgb"].string,
            let rgb = parseRGB(rgbString: rgbString)
        else { return nil }
        
        return ColorItem(name: name, rgb: rgb)
    }
    
    private static func parseRGB(rgbString: String) -> (CGFloat, CGFloat, CGFloat)? {
        let r, g, b: CGFloat
        
        if rgbString.hasPrefix("#") {
            let start = rgbString.index(rgbString.startIndex, offsetBy: 1)
            let hexColor = String(rgbString[start...])
            
            if hexColor.lengthOfBytes(using: .utf8) == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8)  / 255
                    b = CGFloat((hexNumber & 0x0000ff) >> 0)  / 255
                    
                    return (r, g, b)
                }
            }
        }
        
        return nil
    }
}
