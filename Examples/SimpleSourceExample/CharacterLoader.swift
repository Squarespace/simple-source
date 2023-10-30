import Foundation
import CoreData

/// A helper class to load some content into an `NSManagedObjectContext`.
struct CharacterLoader {
    static func load(into context: NSManagedObjectContext) {
        let dataURL = Bundle.main.url(forResource: "characters", withExtension: "json")!
        let data = try! Data(contentsOf: dataURL)
        try! JSONDecoder().decode([CharacterRepresentation].self, from: data).forEach { representation in
            let character = Character(context: context)
            character.name = representation.name
            character.race = representation.race
        }
    }
    
    private struct CharacterRepresentation: Decodable {
        let name: String
        let race: String
    }
}
