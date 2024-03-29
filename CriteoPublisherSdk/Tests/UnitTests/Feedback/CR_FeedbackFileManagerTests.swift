//
//  CR_FeedbackFileManagerTests.swift
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

private let testsActiveMetricsMaxFileSize: UInt = 16 * 1024

class CR_FeedbackFileManagerTests: XCTestCase {

  var fileManipulatingMock: CR_DefaultFileManipulatingMock!
  var feedbackFileManager: CR_FeedbackFileManager!

  override func setUp() {
    super.setUp()
    self.fileManipulatingMock = CR_DefaultFileManipulatingMock()
    self.feedbackFileManager = CR_FeedbackFileManager(
      fileManipulating: self.fileManipulatingMock,
      activeMetricsMaxFileSize: testsActiveMetricsMaxFileSize)
  }

  func testReadMissingFile() {
    let feedbackMessage = self.feedbackFileManager.readFeedback(forFilename: "")
    XCTAssertNil(feedbackMessage)
  }

  func testWriteThenRead() {
    let feedbackMessage1 = CR_FeedbackMessage()
    feedbackMessage1.cdbCallStartTimestamp = now()

    self.feedbackFileManager.writeFeedback(feedbackMessage1, forFilename: "")
    let feedbackMessage2 = self.feedbackFileManager.readFeedback(forFilename: "")

    XCTAssertEqual(feedbackMessage1, feedbackMessage2)
  }

  func testOverwriteThenRead() {
    let feedbackMessage1 = CR_FeedbackMessage()

    feedbackMessage1.cdbCallStartTimestamp = now()
    self.feedbackFileManager.writeFeedback(feedbackMessage1, forFilename: "")

    feedbackMessage1.cdbCallStartTimestamp = now()
    feedbackMessage1.cdbCallEndTimestamp = now()
    self.feedbackFileManager.writeFeedback(feedbackMessage1, forFilename: "")
    let feedbackMessage2 = self.feedbackFileManager.readFeedback(forFilename: "")

    XCTAssertEqual(feedbackMessage1, feedbackMessage2)
  }

  func testRemoveMissingFile() {
    self.feedbackFileManager.removeFile(forFilename: "")
    let feedbackMessage = self.feedbackFileManager.readFeedback(forFilename: "")
    XCTAssertNil(feedbackMessage)
  }

  func testRemoveExistingFile() {
    self.feedbackFileManager.writeFeedback(CR_FeedbackMessage(), forFilename: "")
    let feedbackMessage1 = self.feedbackFileManager.readFeedback(forFilename: "")
    XCTAssertNotNil(feedbackMessage1)

    self.feedbackFileManager.removeFile(forFilename: "")
    let feedbackMessage2 = self.feedbackFileManager.readFeedback(forFilename: "")
    XCTAssertNil(feedbackMessage2)
  }

  func testInitialisationFailedBecauseNoRootDirectory() {
    let mock = self.fileManipulatingMock!
    mock.rootPaths = []
    let feedbackFileManager: CR_FeedbackFileManager? = CR_FeedbackFileManager(
      fileManipulating: mock, activeMetricsMaxFileSize: testsActiveMetricsMaxFileSize)
    XCTAssertNil(feedbackFileManager)
  }

  func testDirectoryExists_ShouldNotCallCreateDirectory() {
    let mock = self.fileManipulatingMock!
    self.feedbackFileManager = CR_FeedbackFileManager(
      fileManipulating: mock,
      activeMetricsMaxFileSize: testsActiveMetricsMaxFileSize)
    XCTAssertEqual(mock.createDirectoryCallCount, 0)
  }

  func testDirectoryNotExists_ShouldCallCreateDirectory() {
    let mock = self.fileManipulatingMock!
    mock.fileExistsResponse = false
    self.feedbackFileManager = CR_FeedbackFileManager(
      fileManipulating: mock,
      activeMetricsMaxFileSize: testsActiveMetricsMaxFileSize)
    XCTAssertEqual(mock.createDirectoryCallCount, 1)
  }

  func testActiveMetricsMaxFileSize() {
    let activeMetricsMaxFileSize: UInt = 123
    let mock = self.fileManipulatingMock!
    mock.sizeOfDirectory = activeMetricsMaxFileSize
    mock.fileExistsResponse = false
    self.feedbackFileManager = CR_FeedbackFileManager(
      fileManipulating: mock, activeMetricsMaxFileSize: activeMetricsMaxFileSize)
    let feedbackMessage = CR_FeedbackMessage()
    self.feedbackFileManager.writeFeedback(feedbackMessage, forFilename: "")
    XCTAssertNil(mock.message, "Feedback should not be written on maxFileSize bound")
  }

  private func now() -> NSNumber {
    return NSNumber(value: NSDate().timeIntervalSince1970)
  }
}

class CR_DefaultFileManipulatingMock: NSObject, CR_FileManipulating {
  var message: CR_FeedbackMessage?
  var contentOfDirectory: [String] = []
  var sizeOfDirectory: UInt = 0
  var rootPaths: [URL] = [URL(fileURLWithPath: "path/to/file")]
  var fileExistsCallCount: Int = 0
  var fileExistsResponse: Bool = true
  var createDirectoryCallCount: Int = 0

  func write(_ data: Data, forAbsolutePath path: String) {
    message = NSKeyedUnarchiver.unarchiveObject(with: data) as? CR_FeedbackMessage
  }

  func readData(forAbsolutePath path: String) -> Data? {
    return message != nil ? NSKeyedArchiver.archivedData(withRootObject: message!) : nil
  }

  func urls(
    for directory: FileManager.SearchPathDirectory,
    inDomains domainMask: FileManager.SearchPathDomainMask
  ) -> [URL] {
    return rootPaths
  }

  var libraryPath: String? {
    rootPaths.first?.path
  }

  func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
    self.fileExistsCallCount += 1
    return self.fileExistsResponse
  }

  func createDirectory(
    atPath path: String,
    withIntermediateDirectories createIntermediates: Bool,
    attributes: [FileAttributeKey: Any]? = nil
  ) throws {
    self.createDirectoryCallCount += 1
  }

  func removeItem(atPath path: String) throws {
    self.message = nil
  }

  func contentsOfDirectory(atPath path: String) throws -> [String] {
    return contentOfDirectory
  }

  func sizeOfDirectory(atPath path: String, error: NSErrorPointer) -> UInt {
    return sizeOfDirectory
  }
}
