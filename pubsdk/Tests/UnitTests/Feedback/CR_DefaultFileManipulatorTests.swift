//
//  CR_DefaultFileManipulatorTests.swift
//  pubsdkTests
//
//  Created by Vincent Guerci on 10/04/2020.
//  Copyright © 2020 Criteo. All rights reserved.
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
        let fileCount = 300, fileSize = 678
        XCTAssertNoThrow(try selfClass.createTestData(fileCount: fileCount, fileSize: fileSize))
        let sizeOfDirectory = self.fileManipulator.sizeOfDirectory(atPath: selfClass.testPath, error: nil)
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
