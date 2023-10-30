import Foundation

public class BasicDataSource<Section>: DataSourceType where Section: SectionType
{
    public let updateHandler = IndexedUpdateHandler()

    public typealias Item = Section.Item
    
    public var sections: [Section] {
        didSet {
            let update = Diff.indexedUpdate(oldData: oldValue, newData: sections)
            updateHandler.send(update: update)
        }
    }
    
    public init(sections: [Section] = []) {
        self.sections = sections
    }

    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfItems(in sectionIndex: Int) -> Int {
        return sections[sectionIndex].items.count
    }
    
    public func sectionAtIndex(sectionIndex: Int) -> Section? {
        return sections[safe: sectionIndex]
    }
    
    public func item(at indexPath: IndexPath) -> Item? {
        return sections[safe: indexPath.section]?.items[safe: indexPath.item]
    }

    public func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var sections = self.sections
        let item = sections[sourceIndexPath.section].items[sourceIndexPath.item]
        sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
        sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.item)
        self.sections = sections
    }
}
