//
//  CR_DefaultFileManipulatorTests.swift
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

import XCTest

class CR_DefaultFileManipulatorTests: XCTestCase {
  var fileManipulator: CR_DefaultFileManipulator!
  static let fileManager = FileManager.default
  static let testPath = (NSTemporaryDirectory() as NSString)
    .appendingPathComponent(NSStringFromClass(CR_DefaultFileManipulatorTests.self))

  override class func setUp() {
    super.setUp()
    XCTAssertNoThrow(try cleanupTestData())
  }

  override func setUp() {
    self.fileManipulator = CR_DefaultFileManipulator()
  }

  override func tearDown() {
    let selfClass = type(of: self)
    XCTAssertNoThrow(try selfClass.cleanupTestData())
  }

  func testSizeOfDirectoryAtPathReturnProperSize() {
    let selfClass = type(of: self)
    let fileCount = 300
    let fileSize = 678
    XCTAssertNoThrow(try selfClass.createTestData(fileCount: fileCount, fileSize: fileSize))
    let sizeOfDirectory = self.fileManipulator.sizeOfDirectory(
      atPath: selfClass.testPath, error: nil)
    XCTAssertEqual(sizeOfDirectory, UInt(fileCount * fileSize))
  }

  func testSizeOfDirectoryPerformance() {
    let selfClass = type(of: self)
    XCTAssertNoThrow(try selfClass.createTestData(fileCount: 1024, fileSize: 64))
    self.measure {
      self.fileManipulator.sizeOfDirectory(atPath: selfClass.testPath, error: nil)
    }
  }

  private static func createTestData(fileCount: Int, fileSize: Int) throws {
    try self.fileManager.createDirectory(atPath: self.testPath, withIntermediateDirectories: false)
    let bytes = malloc(fileSize)!
    let dummyData = Data(bytes: bytes, count: fileSize)
    for i in 1...fileCount {
      let dummyPath = (self.testPath as NSString).appendingPathComponent("dummy\(i)")
      try NSData(data: dummyData).write(toFile: dummyPath)
    }
  }

  private static func cleanupTestData() throws {
    if fileManager.fileExists(atPath: testPath) {
      XCTAssertNoThrow(try fileManager.removeItem(atPath: testPath))
    }
  }
}
