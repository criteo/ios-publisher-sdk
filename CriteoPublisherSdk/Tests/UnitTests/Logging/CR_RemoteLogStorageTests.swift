//
//  CR_RemoteLogStorageTests.swift
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

class CR_RemoteLogStorageTests: XCTestCase {

  let fileManipulatorMock = FileManipulatorMock()
  let queue: CR_CASObjectQueue<CR_RemoteLogRecord> = CR_CASInMemoryObjectQueue<CR_RemoteLogRecord>()
  lazy var remoteLogStorage: CR_RemoteLogStorage = CR_RemoteLogStorage(logQueue: queue)

  override func setUp() {
    super.setUp()
  }

  func test_initWithoutLogs_ShouldDoNothing() {
    XCTAssertEqual(queue.size(), 0)
  }

  func test_pushRecord_ShouldUpdateQueue() {
    let record = createLogRecord()

    remoteLogStorage.push(record)

    XCTAssertEqual(remoteLogStorage.logQueue.size(), 1)
  }

  func test_popRecord_ShouldUpdateQueue() {
    let record = createLogRecord()
    remoteLogStorage.push(record)

    let records = remoteLogStorage.popRemoteLogRecords(42)

    XCTAssertEqual(records.count, 1)
    XCTAssertEqual(remoteLogStorage.logQueue.size(), 0)
  }

  func test_corruptedQueueFile_shouldBeDeleted() {
    XCTAssertNoThrow(
      remoteLogStorage = CorruptedRemoteLogStorage(
        logQueueMaxFileLength: 42, fileManipulator: fileManipulatorMock))

    XCTAssertEqual(fileManipulatorMock.removedItems.count, 1)
  }

  private func createLogRecord() -> CR_RemoteLogRecord {
    CR_RemoteLogRecord(
      version: "0.1.2", bundleId: "bundle", deviceId: "12345", sessionId: "678690", profileId: 42,
      tag: "tag", severity: .info, message: "message", exceptionType: nil)
  }
}

class FileManipulatorMock: NSObject, CR_FileManipulating {
  var removedItems = [String]()

  func write(_ data: Data, forAbsolutePath path: String) {
  }

  func readData(forAbsolutePath path: String) -> Data? {
    fatalError("readData(forAbsolutePath:) has not been implemented")
  }

  func urls(
    for directory: FileManager.SearchPathDirectory,
    inDomains domainMask: FileManager.SearchPathDomainMask
  ) -> [URL] {
    fatalError("urls(for:inDomains:) has not been implemented")
  }

  private(set) var libraryPath: String?

  func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
    fatalError("fileExists(atPath:isDirectory:) has not been implemented")
  }

  func createDirectory(
    atPath path: String, withIntermediateDirectories createIntermediates: Bool,
    attributes: [FileAttributeKey: Any]?
  ) throws {
  }

  func removeItem(atPath path: String) throws {
    removedItems.append(path)
  }

  func contentsOfDirectory(atPath path: String) throws -> [String] {
    fatalError("contentsOfDirectory(atPath:) has not been implemented")
  }

  func sizeOfDirectory(atPath path: String, error: NSErrorPointer) -> UInt {
    fatalError("sizeOfDirectory(atPath:error:) has not been implemented")
  }
}

class CorruptedRemoteLogStorage: CR_RemoteLogStorage {
  var crashedOnce = false

  @objc override func buildQueue(withAbsolutePath: String, maxFileLength: UInt) -> CR_CASObjectQueue<CR_RemoteLogRecord> {
    if !crashedOnce {
      crashedOnce = true
      NSException(name: NSExceptionName.rangeException, reason: "ノಠ益ಠノ彡┻━┻").raise()
    }
    return super.buildQueue(withAbsolutePath: "path", maxFileLength: 42)
  }
}
