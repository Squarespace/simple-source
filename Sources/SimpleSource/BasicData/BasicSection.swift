import Foundation

/// A section usable with `BasicDataSource`.
///
/// - Note:
/// This protocol is only intended for use with a `BasicDataSource`.
public protocol SectionType {
    associatedtype Item: Equatable
    var items: [Item] { get set }
}

/// Enables a `BasicDataSource` to perform in-place updates of modified sections instead of full reloads.
///
/// `IdentifiableSection` is an optional protocol which sections of a `BasicDataSource` can conform to.
///
/// It allows SimpleSource to recognize the sections between data updates. Instead of causing a full reload,
/// changes to the section item arrays will then be analyzed, and a more detailed update will be emitted.
///
/// - Note:
/// This protocol is only intended for use with a `BasicDataSource`.
public protocol IdentifiableSection {
    var sectionIdentifier: String { get }
}

/// Enables a `BasicDataSource` to perform in-place updates of modified items instead of full reloads.
///
/// `IdentifiableItem` is an optional protocol which items of a `BasicDataSource` can conform to.
///
/// It allows SimpleSource to recognize the items between data updates. Instead of changes to an item
/// resulting in a deletion followed by an insertion, this protocol enables SimpleSource to coalesce
/// these into an in-place update of the item instead.
///
/// This can improve the appearance of table and collection view animations for changes.
///
/// Make sure your sections conform to `IdentifiableSection`, or this will have no effect.
///
/// - Note:
/// This protocol is only intended for use with a `BasicDataSource`.
public protocol IdentifiableItem {
    var itemIdentifier: String { get }
}

// MARK: - BasicSection

/// A minimal section for use with `BasicDataSource`.
///
/// This is only provided for convenience. Use a custom type instead for rich sections with attributes such as titles etc.
public struct BasicSection<ItemType: Equatable>: SectionType, Equatable {
    public typealias Item = ItemType
    public var items: [Item]

    public init(items: [Item]) {
        self.items = items
    }
}

extension BasicSection: ExpressibleByArrayLiteral {
    public init(arrayLiteral items: Item...) {
        self.items = items
    }
}

// MARK: - BasicIdentifiableSection

/// A minimal identifiable section for use with `BasicDataSource`.
///
/// This is only provided for convenience. Use a custom type instead for rich sections with attributes such as titles etc.
public struct BasicIdentifiableSection<ItemType: Equatable>: SectionType, IdentifiableSection, Equatable {
    public typealias Item = ItemType
    public var sectionIdentifier: String
    public var items: [Item]

    public init(sectionIdentifier: String, items: [Item]) {
        self.sectionIdentifier = sectionIdentifier
        self.items = items
    }
}
