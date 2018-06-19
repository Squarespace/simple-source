import Foundation
import CoreData
import SwiftyJSON

/// A helper class to load some content into an `NSManagedObjectContext`.
struct CharacterLoader {
    static func load(into context: NSManagedObjectContext) {
        let dataURL = Bundle.main.url(forResource: "characters", withExtension: "json")!
        let data = try! Data(contentsOf: dataURL)
        try! JSON(data: data).arrayValue.forEach {
            loadCharacter(json: $0, into: context)
        }
    }
    
    private static func loadCharacter(json: JSON, into context: NSManagedObjectContext) {
        guard
            let name = json["name"].string,
            let race = json["race"].string
            else { return }
        
        let character = Character(context: context)
        character.name = name
        character.race = race
    }
}
