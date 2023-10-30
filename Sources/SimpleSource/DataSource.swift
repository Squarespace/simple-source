import Foundation

public protocol DataSourceType {
    associatedtype Item
    var updateHandler: IndexedUpdateHandler { get }
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> Item?
}

extension DataSourceType {
    public subscript(indexPath: IndexPath) -> Item? {
        return item(at: indexPath)
    }
    
    public func allItems() -> [Item] {
        return indexPathIterator().compactMap { item(at: $0) }
    }

    public func contains(indexPath: IndexPath) -> Bool {
        return indexPath.section < numberOfSections() && indexPath.item < numberOfItems(in: indexPath.section)
    }

    public func indexPathIterator() -> AnyIterator<IndexPath> {
        let advanceIndexPath = { (indexPath: IndexPath?) -> IndexPath? in
            guard let indexPath = indexPath else { return nil }
            
            let nextItem = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            if self.contains(indexPath: nextItem) { return nextItem }
            
            let nextSection = IndexPath(item: 0, section: indexPath.section + 1)
            if self.contains(indexPath: nextSection) { return nextSection }
            
            return nil
        }
        
        var nextIndexPath: IndexPath? = IndexPath(item: 0, section: 0)
        
        return AnyIterator<IndexPath> {
            let result = nextIndexPath
            nextIndexPath = advanceIndexPath(nextIndexPath)
            return result
        }
    }
}

extension DataSourceType where Item: Equatable {
    public func indexPath(of item: Item) -> IndexPath? {
        return indexPathIterator().first { self.item(at: $0) == item }
    }
}
