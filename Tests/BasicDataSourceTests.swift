import Quick
import Nimble
import SimpleSource

class BasicDataSourceTests: QuickSpec {

    override func spec() {
        describe("A BasicDataSource") {

            typealias Section = BasicSection<String>
            let sectionA = Section(items: ["A1", "A2", "A3"])
            let sectionB = Section(items: ["B1", "B2"])
            let sections = [sectionA, sectionB]
            let dataSource = BasicDataSource(sections: sections)

            it("has the expected number of sections") {
                expect(dataSource.numberOfSections()) == sections.count
            }

            it("has the expected number of items in each section") {
                for sectionIndex in 0 ..< dataSource.numberOfSections() {
                    expect(dataSource.numberOfItems(in: sectionIndex)) == sections[sectionIndex].items.count
                }
            }

            it("contains all the expected items via function lookup") {
                for sectionIndex in 0 ..< dataSource.numberOfSections() {
                    for itemIndex in 0 ..< dataSource.numberOfItems(in: sectionIndex) {
                        let itemIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        expect(dataSource.item(at: itemIndexPath)) == sections[sectionIndex].items[itemIndex]
                    }
                }
            }

            it("exposes the correct data via the sections variable") {
                expect(dataSource.sections) == sections
            }

            it("exposes the correct data via subscripting") {
                for sectionIndex in 0 ..< dataSource.numberOfSections() {
                    for itemIndex in 0 ..< dataSource.numberOfItems(in: sectionIndex) {
                        let itemIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        expect(dataSource[itemIndexPath]) == dataSource.item(at: itemIndexPath)
                    }
                }
            }

            it("exposes the correct data via subscripting") {
                for sectionIndex in 0 ..< dataSource.numberOfSections() {
                    for itemIndex in 0 ..< dataSource.numberOfItems(in: sectionIndex) {
                        let itemIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        expect(dataSource[itemIndexPath]) == dataSource.item(at: itemIndexPath)
                    }
                }
            }

            it("can move items within a section") {
                dataSource.moveItem(
                    at: IndexPath(item: 0, section: 0),
                    to: IndexPath(item: 2, section: 0))

                expect(dataSource.sections) == [["A2", "A3", "A1"], sectionB]

                dataSource.moveItem(
                    at: IndexPath(item: 2, section: 0),
                    to: IndexPath(item: 0, section: 0))

                expect(dataSource.sections) == sections
            }

            it("can move items between sections") {
                dataSource.moveItem(
                    at: IndexPath(item: 0, section: 0),
                    to: IndexPath(item: 0, section: 1))

                expect(dataSource.sections) == [["A2", "A3"], ["A1", "B1", "B2"]]

                dataSource.moveItem(
                    at: IndexPath(item: 2, section: 1),
                    to: IndexPath(item: 1, section: 0))

                expect(dataSource.sections) == [["A2", "B2", "A3"], ["A1", "B1"]]
            }

            it("exposes the correct content through allItems()") {
                expect(dataSource.allItems()) == ["A2", "B2", "A3", "A1", "B1"]

                dataSource.sections = sections

                expect(dataSource.allItems()) == sectionA.items + sectionB.items
            }

            it("can check if an index path is valid") {
                let validIndexPaths = [
                    IndexPath(item: 0, section: 0),
                    IndexPath(item: 1, section: 0),
                    IndexPath(item: 2, section: 0),
                    IndexPath(item: 0, section: 1),
                    IndexPath(item: 1, section: 1)
                ]

                for indexPath in validIndexPaths {
                    expect(dataSource.contains(indexPath: indexPath)) == true
                }

                let invalidIndexPaths = [
                    IndexPath(item: 3, section: 0),
                    IndexPath(item: 100, section: 0),
                    IndexPath(item: 0, section: 10),
                    IndexPath(item: 500, section: 5)
                ]

                for indexPath in invalidIndexPaths {
                    expect(dataSource.contains(indexPath: indexPath)) == false
                }
            }

            it("can iterate across all valid index paths") {
                var collectedItems: [String] = []
                for indexPath in dataSource.indexPathIterator() {
                    if let item = dataSource[indexPath] {
                        collectedItems.append(item)
                    }
                    expect(dataSource.contains(indexPath: indexPath)) == true
                }
                expect(collectedItems) == dataSource.allItems()
            }
        }
    }
}
