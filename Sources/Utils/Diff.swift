import Foundation
import Dwifft

private struct WrappedIdentifiableSection<T: SectionType> {
    private let value: T
    private let section: IdentifiableSection
    
    init?(value: T) {
        guard let s = value as? IdentifiableSection else { return nil}
        self.value = value
        self.section = s
    }
    
    var sectionIdentifier: String {
        return section.sectionIdentifier
    }
    
    var items: [T.Item] {
        return value.items
    }
}

struct Diff {
    
    static func indexedUpdate<T>(oldData: [T], newData: [T]) -> IndexedUpdate where T: SectionType {
        let wrappedOldData = oldData.compactMap { WrappedIdentifiableSection(value: $0) }
        let wrappedNewData = newData.compactMap { WrappedIdentifiableSection(value: $0) }
        guard (wrappedOldData.count == oldData.count) && (wrappedNewData.count == newData.count) else { return .full }
        return indexedUpdate(oldData: wrappedOldData, newData: wrappedNewData)
    }
    
    private static func indexedUpdate<T>(oldData: [WrappedIdentifiableSection<T>], newData: [WrappedIdentifiableSection<T>]) -> IndexedUpdate {
        var insertedSections = IndexSet()
        var deletedSections = IndexSet()
        var insertedRows = [IndexPath]()
        var updatedRows = [IndexPath]()
        var deletedRows = [IndexPath]()

        let oldSectionIdentifiers = oldData.map { $0.sectionIdentifier }
        let newSectionIdentifiers = newData.map { $0.sectionIdentifier }
        
        let sectionsDiff = Dwifft.diff(oldSectionIdentifiers, newSectionIdentifiers)

        sectionsDiff.forEach { step in
            switch step {
            case .insert:
                insertedSections.insert(step.idx)
            case .delete:
                deletedSections.insert(step.idx)
            }
        }

        newData.enumerated().forEach { sectionIndex, newSection in
            if insertedSections.contains(sectionIndex) { return }
            guard
                let oldSectionIndex = oldSectionIdentifiers.firstIndex(of: newSection.sectionIdentifier),
                let oldSection = oldData[safe: oldSectionIndex] else { return }

            // OPTIMIZATION:
            //
            // If `Item` conforms to `IdentifiableItem` and we can see that the section changes are strictly in-place updates
            // we update the items in place for this section, instead of deleting and reinserting them.
            //
            // KNOWN SHORTCOMING:
            //
            // This will not catch every in-place reload. If in-place updates are mixed with real inserts or deletes
            // they can be tricky to track.
            let oldIdentifiers = oldSection.items.compactMap { ($0 as? IdentifiableItem)?.itemIdentifier }
            let newIdentifiers = newSection.items.compactMap { ($0 as? IdentifiableItem)?.itemIdentifier }
            if oldIdentifiers.count == oldSection.items.count, newIdentifiers.count == newSection.items.count, oldIdentifiers == newIdentifiers {
                // All items are identifiable. The section contains the same items in the same order before and after the update.
                // We convert any changed items to in-place updates.
                updatedRows += zip(oldSection.items, newSection.items)
                    .enumerated()
                    .filter { $0.element.0 != $0.element.1 }
                    .map { IndexPath(item: $0.offset, section: sectionIndex) }
            } else {
                // Calculate a diff to transform the old section items into the new section items. No in-place updates will be emitted.
                Dwifft.diff(oldSection.items, newSection.items)
                    .forEach { step in
                        switch step {
                        case .insert:
                            let indexPath = IndexPath(item: step.idx, section: sectionIndex)
                            insertedRows.append(indexPath)
                        case .delete:
                            let indexPath = IndexPath(item: step.idx, section: oldSectionIndex)
                            deletedRows.append(indexPath)
                        }
                    }
            }
        }
        
        return .delta(
            insertedSections: insertedSections,
            updatedSections: IndexSet(),
            deletedSections: deletedSections,
            insertedRows: insertedRows,
            updatedRows: updatedRows,
            deletedRows: deletedRows
        )
    }
}
