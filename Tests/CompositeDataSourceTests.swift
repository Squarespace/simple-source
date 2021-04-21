import Quick
import Nimble
import SimpleSource

class CompositeDataSourceTests: QuickSpec {

    override func spec() {
        describe("A basic `CompositeDataSource`") {
            typealias SimpleCompositeDataSource = CompositeDataSource<DataSourceA, DataSourceB>
            typealias DataSourceA = BasicDataSource<BasicIdentifiableSection<String>>
            typealias DataSourceB = BasicDataSource<BasicIdentifiableSection<Int>>

            let stringSectionA = BasicIdentifiableSection(sectionIdentifier: "stringsA", items: [
                "Section A - Item 0",
                "Section A - Item 1",
                "Section A - Item 2",
                "Section A - Item 3",
                "Section A - Item 4",
                "Section A - Item 5",
                "Section A - Item 6",
            ])
            let stringSectionB = BasicIdentifiableSection(sectionIdentifier: "stringsB", items: [
                "Section B - Item 0",
                "Section B - Item 1",
                "Section B - Item 2",
            ])
            let intSectionA = BasicIdentifiableSection(sectionIdentifier: "intsA", items: [
                1000,
                1001,
                1002,
                1003,
                1004,
            ])
            let intSectionB = BasicIdentifiableSection(sectionIdentifier: "intsB", items: [
                1100,
                1101,
                1102,
                1103,
                1104,
                1105,
                1106,
                1107,
                1108,
            ])
            let intSectionC = BasicIdentifiableSection(sectionIdentifier: "intsC", items: [
                1200,
                1201,
            ])
            let sections = [
                stringSectionA.items,
                stringSectionB.items,
                intSectionA.items,
                intSectionB.items,
                intSectionC.items
            ] as [[Any]]

            let dataSourceA = DataSourceA(sections: [stringSectionA, stringSectionB])
            let dataSourceB = DataSourceB(sections: [intSectionA, intSectionB, intSectionC])
            let compositeDataSource = SimpleCompositeDataSource(
                firstDataSource: dataSourceA,
                secondDataSource: dataSourceB
            )

            let startingItemLookup = { (indexPath: IndexPath) -> SimpleCompositeDataSource.Item? in
                switch indexPath.section {
                case 0: return .A(stringSectionA.items[indexPath.row])
                case 1: return .A(stringSectionB.items[indexPath.row])
                case 2: return .B(intSectionA.items[indexPath.row])
                case 3: return .B(intSectionB.items[indexPath.row])
                case 4: return .B(intSectionC.items[indexPath.row])
                default: return nil
                }
            }
            let currentItemLookup = { (indexPath: IndexPath) -> SimpleCompositeDataSource.Item? in
                compositeDataSource.item(at: indexPath)
            }

            describe("initial state") {
                it("should have expected number of sections") {
                    expect(compositeDataSource.numberOfSections()).to(equal(sections.count))
                }

                it("should have expected number of items per section") {
                    for section in 0 ..< compositeDataSource.numberOfSections() {
                        expect(compositeDataSource.numberOfItems(in: section)).to(equal(sections[section].count))
                    }
                }

                it("should have the items in the correct order") {
                    for sectionIndex in 0 ..< compositeDataSource.numberOfSections() {
                        for itemIndex in 0 ..< compositeDataSource.numberOfItems(in: sectionIndex) {
                            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                            expect(startingItemLookup(indexPath)).to(equal(currentItemLookup(indexPath)))
                        }
                    }
                }
            }

            describe("state changes") {
                var receivedChanges = [IndexedUpdate]()
                var changesSubscription: IndexedUpdateHandler.Subscription?

                beforeEach {
                    receivedChanges.removeAll()
                    changesSubscription = compositeDataSource.updateHandler.subscribe { receivedChanges += [$0] }
                    expect(changesSubscription).toNot(be(nil)) // Did this to shut up warning about unread variable
                }

                context("dataSourceA gets a new second section") {
                    let newSecondSection = BasicIdentifiableSection(sectionIdentifier: "stringsB", items: [
                        "This is item 1.0",
                        "This is item 1.1",
                    ])

                    beforeEach { dataSourceA.sections = [stringSectionA, newSecondSection] }
                    afterEach { dataSourceA.sections = [stringSectionA, stringSectionB] }

                    it("should signal the correct delta") {
                        expect(receivedChanges.count).to(be(1))
                        let expectedUpdate = IndexedUpdate.delta(
                            insertedSections: .init(),
                            updatedSections: .init(),
                            deletedSections: .init(),
                            insertedRows: [
                                .init(item: 0, section: 1),
                                .init(item: 1, section: 1)
                            ],
                            updatedRows: [],
                            deletedRows: [
                                .init(item: 2, section: 1),
                                .init(item: 1, section: 1),
                                .init(item: 0, section: 1),
                            ]
                        )
                        expect(receivedChanges.first).to(equal(expectedUpdate))
                    }

                    it("should contain the right data where expected") {
                        for sectionIndex in 0 ..< compositeDataSource.numberOfSections() {
                            for itemIndex in 0 ..< compositeDataSource.numberOfItems(in: sectionIndex) {
                                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                                switch sectionIndex {
                                case 1:
                                    expect(currentItemLookup(indexPath)).to(equal(.A(newSecondSection.items[itemIndex])))
                                default:
                                    expect(currentItemLookup(indexPath)).to(equal(startingItemLookup(indexPath)))
                                }
                            }
                        }
                    }
                }

                context("dataSourceB gets a new second section") {
                    let newSecondSection = BasicIdentifiableSection(sectionIdentifier: "intsB", items: [
                        2300,
                        2301,
                        2302,
                        2303,
                        2304,
                    ])

                    beforeEach { dataSourceB.sections = [intSectionA, newSecondSection, intSectionC] }
                    afterEach { dataSourceB.sections = [intSectionA, intSectionB, intSectionC] }

                    it("should signal the correct delta") {
                        expect(receivedChanges.count).to(be(1))
                        let expectedUpdate = IndexedUpdate.delta(
                            insertedSections: .init(),
                            updatedSections: .init(),
                            deletedSections: .init(),
                            insertedRows: [
                                .init(item: 0, section: 3),
                                .init(item: 1, section: 3),
                                .init(item: 2, section: 3),
                                .init(item: 3, section: 3),
                                .init(item: 4, section: 3),
                            ],
                            updatedRows: [],
                            deletedRows: [
                                .init(item: 8, section: 3),
                                .init(item: 7, section: 3),
                                .init(item: 6, section: 3),
                                .init(item: 5, section: 3),
                                .init(item: 4, section: 3),
                                .init(item: 3, section: 3),
                                .init(item: 2, section: 3),
                                .init(item: 1, section: 3),
                                .init(item: 0, section: 3),
                            ]
                        )
                        expect(receivedChanges.first).to(equal(expectedUpdate))
                    }

                    it("should contain the right data where expected") {
                        for sectionIndex in 0 ..< compositeDataSource.numberOfSections() {
                            for itemIndex in 0 ..< compositeDataSource.numberOfItems(in: sectionIndex) {
                                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                                switch sectionIndex {
                                case 3:
                                    expect(currentItemLookup(indexPath)).to(equal(.B(newSecondSection.items[itemIndex])))
                                default:
                                    expect(currentItemLookup(indexPath)).to(equal(startingItemLookup(indexPath)))
                                }
                            }
                        }
                    }
                }
            }

        }
    }

}
