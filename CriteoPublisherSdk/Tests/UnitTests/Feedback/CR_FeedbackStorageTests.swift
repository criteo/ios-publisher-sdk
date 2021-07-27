//
//  CR_FeedbackStorageTests.swift
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest

class CR_FeedbackStorageTests: XCTestCase {

  var fileManagingMock: CR_FeedbackFileManagingMock = CR_FeedbackFileManagingMock()
  var queue: CR_CASObjectQueue<CR_FeedbackMessage> = CR_CASInMemoryObjectQueue<CR_FeedbackMessage>()
  var feedbackStorage: CR_FeedbackStorage = CR_FeedbackStorage()
  var impressionId1: String = "impressionId"
  var impressionId2: String = "impressionId2"
  var timestamp1: NSNumber = 100
  var timestamp2: NSNumber = 101

  override func setUp() {
    super.setUp()
    fileManagingMock = CR_FeedbackFileManagingMock()
    queue = CR_CASInMemoryObjectQueue<CR_FeedbackMessage>()
    feedbackStorage = CR_FeedbackStorage(fileManager: fileManagingMock, with: queue)
  }

  func test_initWithoutActiveMessages_ShouldDoNothing() {
    XCTAssertEqual(queue.size(), 0)
    XCTAssertEqual(fileManagingMock.readFeedbackCallCount, 0)
    XCTAssertEqual(fileManagingMock.removeFileCallCount, 0)
  }

  func test_initWithActiveMessages_ShouldBeMovedToSendingQueue() throws {
    fileManagingMock = CR_FeedbackFileManagingMock()
    fileManagingMock.allActiveFeedbackFilenamesResult = ["fn1", "fn2"]
    fileManagingMock.readFeedbackResults = [
      createMessageWithImpId("1"), createMessageWithImpId("2"),
    ]
    feedbackStorage = CR_FeedbackStorage(fileManager: fileManagingMock, with: queue)

    XCTAssertEqual(queue.size(), 2)
    XCTAssertEqual(fileManagingMock.readFeedbackCallCount, 2)
    XCTAssertEqual(fileManagingMock.removeFileCallCount, 2)
    XCTAssertEqual(try getAllItemsFromQueue(), fileManagingMock.readFeedbackResults)
  }

  func test_requestFor_ReadyToSendMessages_ShouldReturnEverythingFromQueue() throws {
    try queue.add(createMessageWithImpId("1"), error: ())
    try queue.add(createMessageWithImpId("3"), error: ())
    XCTAssertEqual(try getAllItemsFromQueue(), feedbackStorage.popMessagesToSend())
  }

  func test_requestFor_ReadyToSendMessages_ShouldReturnEverythingFromQueue2() throws {
    try queue.add(createMessageWithImpId("1"), error: ())
    try queue.add(createMessageWithImpId("3"), error: ())
    feedbackStorage.popMessagesToSend()
    XCTAssertEqual(queue.size(), 0)
  }

  func test_updateNonexistentMessage_ShouldCreateFile() {
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp1
    }
    XCTAssertEqual(fileManagingMock.readFeedbackCallCount, 1)
    XCTAssertEqual(fileManagingMock.writeFeedbackCallCount, 1)
    XCTAssertEqual(fileManagingMock.writeFeedbackResults.count, 1)
    XCTAssertEqual(fileManagingMock.writeFeedbackResults[0].cdbCallStartTimestamp, timestamp1)
  }

  func test_updateExistingMessage_ShouldUpdateExistingFile() {
    let existingMessage = createMessageWithImpId(impressionId1)
    existingMessage.cdbCallStartTimestamp = timestamp1
    fileManagingMock.readFeedbackResults = [existingMessage]
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp2
    }
    XCTAssertEqual(fileManagingMock.writeFeedbackResults[0].cdbCallStartTimestamp, timestamp2)
    XCTAssertEqual(existingMessage.cdbCallStartTimestamp, timestamp2)
  }

  func test_updateBySameAdUnit_shouldReadBySameFilename() {
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp1
    }
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp2
    }
    XCTAssertEqual(fileManagingMock.readRequestedFilenames.count, 2)
    XCTAssertEqual(
      fileManagingMock.readRequestedFilenames[0], fileManagingMock.readRequestedFilenames[1])
  }

  func test_updateByDifferentAdUnit_shouldReadByDifferentFilename() {
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp1
    }
    feedbackStorage.updateMessage(withImpressionId: impressionId2) {
      $0.cdbCallStartTimestamp = self.timestamp1
    }
    XCTAssertEqual(fileManagingMock.readRequestedFilenames.count, 2)
    XCTAssertNotEqual(
      fileManagingMock.readRequestedFilenames[0], fileManagingMock.readRequestedFilenames[1])
  }

  func test_updateSameObjectTwice_ShouldUpdateSingleObject() {
    let message = createMessageWithImpId(impressionId1)
    fileManagingMock.readFeedbackResults = [message, message]

    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp1
    }
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp2
    }

    XCTAssertEqual(fileManagingMock.writeFeedbackResults.count, 2)
    XCTAssertEqual(fileManagingMock.writeFeedbackResults[0], message)
    XCTAssertEqual(fileManagingMock.writeFeedbackResults[1], message)
  }

  func test_updateDifferentObjects() {
    fileManagingMock.readFeedbackResults = [
      createMessageWithImpId(impressionId1), createMessageWithImpId(impressionId2),
    ]
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.cdbCallStartTimestamp = self.timestamp1
    }
    feedbackStorage.updateMessage(withImpressionId: impressionId2) {
      $0.cdbCallStartTimestamp = self.timestamp2
    }
    XCTAssertEqual(fileManagingMock.writeFeedbackResults.count, 2)
    XCTAssertNotEqual(
      fileManagingMock.writeFeedbackResults[0], fileManagingMock.writeFeedbackResults[1])
  }

  func test_updateMessageToRTS_messageShouldBeMovedToSendingQueue() {
    feedbackStorage.updateMessage(withImpressionId: impressionId1) {
      $0.elapsedTimestamp = self.timestamp1
    }
    XCTAssertEqual(fileManagingMock.removeFileCallCount, 1)
    XCTAssertEqual(queue.size(), 1)
  }

  func test_corruptedQueueFile_shouldBeDeleted() {
    XCTAssertNoThrow(
      feedbackStorage = CR_FeedbackCorruptedStorage(
        sendingQueueMaxSize: 5, fileManager: fileManagingMock))
    XCTAssertEqual(fileManagingMock.removeSendingQueueFileCount, 1)
  }

  private func getAllItemsFromQueue() throws -> [CR_FeedbackMessage] {
    return try queue.peek(queue.size(), error: ())
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
  @objc var writeFeedbackResults: [CR_FeedbackMessage] = []
  var writeRequestedFilenames: [String] = []

  var allActiveFeedbackFilenamesResult: [String] = []
  var removeFileCallCount: Int = 0
  @objc var removeRequestedFilenames: [String] = []

  @objc var useReadWriteDictionary: Bool = false
  @objc var readWriteDictionary: Dictionary = [String: CR_FeedbackMessage]()

  @objc var sendingQueueFilePath: String = ""
  var removeSendingQueueFileCount: Int = 0

  /// We use a synchronization queue to prevent data races.
  var syncQueue: DispatchQueue = DispatchQueue(
    label: "com.criteo.sdk.publisher.test.CR_FeedbackFileManagingMock")

  func readFeedback(forFilename filename: String) -> CR_FeedbackMessage? {
    var result: CR_FeedbackMessage?
    syncQueue.sync {
      if useReadWriteDictionary {
        result = readWriteDictionary[filename]
      }

      if result == nil {
        result =
          readFeedbackCallCount < readFeedbackResults.count
          ? readFeedbackResults[readFeedbackCallCount] : nil
      }

      readFeedbackCallCount += 1
      readRequestedFilenames.append(filename)
    }
    return result
  }

  func writeFeedback(_ feedback: CR_FeedbackMessage, forFilename filename: String) {
    syncQueue.sync {
      writeFeedbackCallCount += 1
      writeFeedbackResults.append(feedback)
      writeRequestedFilenames.append(filename)

      if useReadWriteDictionary {
        readWriteDictionary[filename] = feedback
      }
    }
  }

  func removeFile(forFilename filename: String) {
    syncQueue.sync {
      removeFileCallCount += 1
      removeRequestedFilenames.append(filename)

      if useReadWriteDictionary {
        readWriteDictionary.removeValue(forKey: filename)
      }
    }
  }

  func allActiveFeedbackFilenames() -> [String] {
    return allActiveFeedbackFilenamesResult
  }

  func removeSendingQueueFile() {
    removeSendingQueueFileCount += 1
  }
}

class CR_FeedbackCorruptedStorage: CR_FeedbackStorage {
  var crashedOnce = false

  @objc override func buildSendingQueue(withMaxSize: UInt, fileManager: CR_FeedbackFileManager!)
    -> CR_CASObjectQueue<CR_FeedbackMessage>
  {
    if !crashedOnce {
      crashedOnce = true
      NSException(name: NSExceptionName.rangeException, reason: "ノಠ益ಠノ彡┻━┻").raise()
    }
    return super.buildSendingQueue(withMaxSize: withMaxSize, fileManager: fileManager)
  }
}
