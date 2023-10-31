import Foundation
import Nimble
import Quick
@testable import SimpleSource

class IndexedUpdateHandlerTests: QuickSpec {

    override class func spec() {
        describe("An IndexedUpdateHandler") {
            let updateHandler = IndexedUpdateHandler()
            var subscriptions: [IndexedUpdateHandler.Subscription]!

            beforeEach {
                subscriptions = []
            }

            it("forwards full updates to a subscribed observer") {
                var receivedFullUpdates = 0
                subscriptions.append(updateHandler.subscribe { update in
                    if case .full = update {
                        receivedFullUpdates = receivedFullUpdates + 1
                    } else {
                        fail("Unexpected update received.")
                    }
                })

                updateHandler.sendFullUpdate()
                expect(receivedFullUpdates) == 1

                updateHandler.send(update: .full)
                expect(receivedFullUpdates) == 2
            }

            it("forwards delta updates to a subscribed observer") {
                var receivedUpdates: [IndexedUpdate] = []

                subscriptions.append(updateHandler.subscribe { update in
                    receivedUpdates.append(update)
                })

                let sentInsertedSections = IndexSet([1, 2])
                let sentUpdatedSections = IndexSet([3, 4, 5])
                let sentDeletedSections = IndexSet([6, 7])
                let sentInsertedRows =  [IndexPath(item: 1, section: 20)]
                let sentUpdatedRows = [IndexPath(item: 0, section: 1), IndexPath(item: 10, section: 11)]
                let sentDeletedRows = [IndexPath(item: 100, section: 100)]

                updateHandler.send(update: .delta(
                    insertedSections: sentInsertedSections,
                    updatedSections: sentUpdatedSections,
                    deletedSections: sentDeletedSections,
                    insertedRows: sentInsertedRows,
                    updatedRows: sentUpdatedRows,
                    deletedRows: sentDeletedRows))

                expect(receivedUpdates.count) == 1

                switch receivedUpdates[0] {
                case let .delta(
                    insertedSections: receivedInsertedSections,
                    updatedSections: receivedUpdatedSections,
                    deletedSections: receivedDeletedSections,
                    insertedRows: receivedInsertedRows,
                    updatedRows: receivedUpdatedRows,
                    deletedRows: receivedDeletedRows):
                    expect(receivedInsertedSections) == sentInsertedSections
                    expect(receivedUpdatedSections) == sentUpdatedSections
                    expect(receivedDeletedSections) == sentDeletedSections
                    expect(receivedInsertedRows) == sentInsertedRows
                    expect(receivedUpdatedRows) == sentUpdatedRows
                    expect(receivedDeletedRows) == sentDeletedRows
                case .full:
                    fail("Unexpected update received.")
                }
            }

            it("stops sending updates to removed observers") {
                var updatesForSubscriptionA = 0
                var updatesForSubscriptionB = 0

                subscriptions.append(updateHandler.subscribe { _ in
                    updatesForSubscriptionA = updatesForSubscriptionA + 1
                })

                updateHandler.sendFullUpdate()
                expect(updatesForSubscriptionA) == 1
                expect(updatesForSubscriptionB) == 0

                subscriptions.append(updateHandler.subscribe { _ in
                    updatesForSubscriptionB = updatesForSubscriptionB + 1
                })

                updateHandler.sendFullUpdate()
                expect(updatesForSubscriptionA) == 2
                expect(updatesForSubscriptionB) == 1

                _ = subscriptions.removeLast()

                updateHandler.sendFullUpdate()
                expect(updatesForSubscriptionA) == 3
                expect(updatesForSubscriptionB) == 1

                _ = subscriptions.removeLast()

                updateHandler.sendFullUpdate()
                expect(updatesForSubscriptionA) == 3
                expect(updatesForSubscriptionB) == 1

                expect(subscriptions.isEmpty) == true
            }

            it("properly removes observation closures") {
                class TestObject {}
                weak var weakObject: TestObject?
                do {
                    let object = TestObject()
                    weakObject = object
                    subscriptions.append(updateHandler.subscribe { [object] _ in _ = object })
                }

                expect(weakObject).toNot(beNil())
                subscriptions = []
                expect(weakObject).to(beNil())
            }
        }
    }
}
