//
// Created by Aleksandr Pakhmutov on 25/02/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

import Foundation
import XCTest

class CR_FeedbackStorageTests: XCTestCase {

    var fileManagingMock: CR_FeedbackFileManagingMock = CR_FeedbackFileManagingMock()
    var queue: CASObjectQueue<CR_FeedbackMessage> = CASInMemoryObjectQueue<CR_FeedbackMessage>()
    var feedbackStorage: CR_FeedbackStorage = CR_FeedbackStorage()
    var adUnit: CR_CacheAdUnit = CR_CacheAdUnit(adUnitId: "adUnitId", width: 320, height: 50)
    var adUnit2: CR_CacheAdUnit = CR_CacheAdUnit(adUnitId: "adUnitId2", width: 320, height: 50)
    var newImpressionId: String = "newImpressionId"

    override func setUp() {
        super.setUp()
        fileManagingMock = CR_FeedbackFileManagingMock()
        queue = CASInMemoryObjectQueue<CR_FeedbackMessage>()
        feedbackStorage = CR_FeedbackStorage(fileManager: fileManagingMock, with: queue)
    }

    func test_initWithoutActiveMessages_ShouldDoNothing() {
        XCTAssertEqual(queue.size(), 0)
        XCTAssertEqual(fileManagingMock.readFeedbackCallCount, 0)
        XCTAssertEqual(fileManagingMock.removeFileCallCount, 0)
    }

    func test_initWithActiveMessages_ShouldBeMovedToSendingQueue() {
        fileManagingMock = CR_FeedbackFileManagingMock()
        fileManagingMock.allActiveFeedbackFilenamesResult = ["fn1", "fn2"]
        fileManagingMock.readFeedbackResults = [createMessageWithImpId("1"), createMessageWithImpId("2")]
        feedbackStorage = CR_FeedbackStorage(fileManager: fileManagingMock, with: queue)

        XCTAssertEqual(queue.size(), 2)
        XCTAssertEqual(fileManagingMock.readFeedbackCallCount, 2)
        XCTAssertEqual(fileManagingMock.removeFileCallCount, 2)
        XCTAssertEqual(getAllItemsFromQueue(), fileManagingMock.readFeedbackResults)
    }

    func test_requestFor_ReadyToSendMessages_ShouldReturnEverythingFromQueue() {
        queue.add(createMessageWithImpId("1"))
        queue.add(createMessageWithImpId("3"))
        XCTAssertEqual(getAllItemsFromQueue(), feedbackStorage.messagesReadyToSend())
    }

    func test_requestFor_ReadyToSendMessages_ShouldReturnEverythingFromQueue2() {
        queue.add(createMessageWithImpId("1"))
        queue.add(createMessageWithImpId("3"))
        feedbackStorage.removeFirstMessages(withCount: 2)
        XCTAssertEqual(queue.size(), 0)
    }

    func test_updateNonexistentMessage_ShouldCreateFile() {
        feedbackStorage.updateMessage(with: adUnit) { $0.impressionId = self.newImpressionId }
        XCTAssertEqual(fileManagingMock.readFeedbackCallCount, 1)
        XCTAssertEqual(fileManagingMock.writeFeedbackCallCount, 1)
        XCTAssertEqual(fileManagingMock.writeFeedbackResults.count, 1)
        XCTAssertEqual(fileManagingMock.writeFeedbackResults[0].impressionId, newImpressionId)
    }

    func test_updateExistingMessage_ShouldUpdateExistingFile() {
        let existingMessage = createMessageWithImpId("oldImpressionId")
        fileManagingMock.readFeedbackResults = [existingMessage]
        feedbackStorage.updateMessage(with: adUnit) { $0.impressionId = self.newImpressionId }
        XCTAssertEqual(fileManagingMock.writeFeedbackResults[0].impressionId, newImpressionId)
        XCTAssertEqual(existingMessage.impressionId, newImpressionId)
    }

    func test_updateBySameAdUnit_shouldReadBySameFilename() {
        feedbackStorage.updateMessage(with: adUnit) { $0.impressionId = self.newImpressionId }
        feedbackStorage.updateMessage(with: adUnit) { $0.impressionId = self.newImpressionId }
        XCTAssertEqual(fileManagingMock.readRequestedFilenames.count, 2)
        XCTAssertEqual(fileManagingMock.readRequestedFilenames[0], fileManagingMock.readRequestedFilenames[1])
    }

    func test_updateByDifferentAdUnit_shouldReadByDifferentFilename() {
        feedbackStorage.updateMessage(with: adUnit) { $0.impressionId = self.newImpressionId }
        feedbackStorage.updateMessage(with: adUnit2) { $0.impressionId = self.newImpressionId }
        XCTAssertEqual(fileManagingMock.readRequestedFilenames.count, 2)
        XCTAssertNotEqual(fileManagingMock.readRequestedFilenames[0], fileManagingMock.readRequestedFilenames[1])
    }

    func test_updateSameObjectTwice_ShouldUpdateSingleObject() {
        let message = createMessageWithImpId("new")
        fileManagingMock.readFeedbackResults = [message, message]

        feedbackStorage.updateMessage(with: adUnit) { $0.impressionId = "abc" }
        feedbackStorage.updateMessage(with: adUnit) { $0.impressionId = self.newImpressionId }

        XCTAssertEqual(fileManagingMock.writeFeedbackResults.count, 2)
        XCTAssertEqual(fileManagingMock.writeFeedbackResults[0], message)
        XCTAssertEqual(fileManagingMock.writeFeedbackResults[1], message)
    }

    func test_updateDifferentObjects() {
        fileManagingMock.readFeedbackResults = [createMessageWithImpId("abc"), createMessageWithImpId("abc")]
        feedbackStorage.updateMessage(with: adUnit) { $0.cdbCallStartTimestamp = 10 }
        feedbackStorage.updateMessage(with: adUnit2) { $0.cdbCallStartTimestamp = 20 }
        XCTAssertEqual(fileManagingMock.writeFeedbackResults.count, 2)
        XCTAssertNotEqual(fileManagingMock.writeFeedbackResults[0], fileManagingMock.writeFeedbackResults[1])
    }

    func test_updateMessageToRTS_messageShouldBeMovedToSendingQueue() {
        feedbackStorage.updateMessage(with: adUnit) { $0.elapsedTimestamp = 10 }
        XCTAssertEqual(fileManagingMock.removeFileCallCount, 1)
        XCTAssertEqual(queue.size(), 1)
    }

    private func getAllItemsFromQueue() -> [CR_FeedbackMessage] {
        queue.peek(queue.size())
    }

    private func createMessageWithImpId(_ impId: String) -> CR_FeedbackMessage {
        let message = CR_FeedbackMessage()
        message.impressionId = impId
        return message
    }
}

class CR_FeedbackFileManagingMock: NSObject, CR_FeedbackFileManaging {

    var readFeedbackCallCount: Int = 0
    var readFeedbackResults: [CR_FeedbackMessage] = []
    var readRequestedFilenames: [String] = []

    var writeFeedbackCallCount: Int = 0
    var writeFeedbackResults: [CR_FeedbackMessage] = []

    var allActiveFeedbackFilenamesResult: [String] = []
    var removeFileCallCount: Int = 0

    func readFeedback(forFilename filename: String) -> CR_FeedbackMessage? {
        let res = readFeedbackCallCount < readFeedbackResults.count ? readFeedbackResults[readFeedbackCallCount] : nil
        readFeedbackCallCount += 1
        readRequestedFilenames.append(filename)
        return res
    }

    func writeFeedback(_ feedback: CR_FeedbackMessage, forFilename filename: String) {
        writeFeedbackCallCount += 1
        writeFeedbackResults.append(feedback)
    }

    func removeFile(forFilename filename: String) {
        removeFileCallCount += 1
    }

    func allActiveFeedbackFilenames() -> [String] {
        allActiveFeedbackFilenamesResult
    }
}
