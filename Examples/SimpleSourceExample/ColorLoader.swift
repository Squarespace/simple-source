import Foundation

struct ColorLoader {
    
    /// Loads colors (organized into sections) from a JSON file.
    static func loadSections() -> [ColorSection] {
        let dataURL = Bundle.main.url(forResource: "colors", withExtension: "json")!
        let data = try! Data(contentsOf: dataURL)
        return try! JSONDecoder().decode([ColorSection].self, from: data)
    }
}
