//
//  CR_FeedbackFileManagerTests.swift
//  pubsdkTests
//
//  Copyright © 2020 Criteo. All rights reserved.
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
        self.feedbackFileManager = CR_FeedbackFileManager(fileManipulating: self.fileManipulatingMock,
                activeMetricsMaxFileSize: testsActiveMetricsMaxFileSize)
    }

    func testReadMissingFile() {
        let x = self.feedbackFileManager.readFeedback(forFilename: "")
        XCTAssertNil(x)
    }

    func testWriteThenRead() {
        let x = CR_FeedbackMessage()
        x.cdbCallStartTimestamp = now()

        self.feedbackFileManager.writeFeedback(x, forFilename: "")
        let x1 = self.feedbackFileManager.readFeedback(forFilename: "")

        XCTAssertEqual(x, x1)
    }

    func testOverwriteThenRead() {
        let x = CR_FeedbackMessage()

        x.cdbCallStartTimestamp = now()
        self.feedbackFileManager.writeFeedback(x, forFilename: "")

        x.cdbCallStartTimestamp = now()
        x.cdbCallEndTimestamp = now()
        self.feedbackFileManager.writeFeedback(x, forFilename: "")
        let x1 = self.feedbackFileManager.readFeedback(forFilename: "")

        XCTAssertEqual(x, x1)
    }

    func testRemoveMissingFile() {
        self.feedbackFileManager.removeFile(forFilename: "")
        let x = self.feedbackFileManager.readFeedback(forFilename: "")
        XCTAssertNil(x)
    }

    func testRemoveExistingFile() {
        self.feedbackFileManager.writeFeedback(CR_FeedbackMessage(), forFilename: "")
        let x = self.feedbackFileManager.readFeedback(forFilename: "")
        XCTAssertNotNil(x)

        self.feedbackFileManager.removeFile(forFilename: "")
        let x1 = self.feedbackFileManager.readFeedback(forFilename: "")
        XCTAssertNil(x1)
    }

    func testInitialisationFailedBecauseNoRootDirectory() {
        let mock = self.fileManipulatingMock!
        mock.rootPaths = []
        let x = CR_FeedbackFileManager(
                fileManipulating: mock,
                activeMetricsMaxFileSize: testsActiveMetricsMaxFileSize) as CR_FeedbackFileManager?
        XCTAssertNil(x)
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
                fileManipulating: mock,
                activeMetricsMaxFileSize: activeMetricsMaxFileSize)
        let x = CR_FeedbackMessage()
        self.feedbackFileManager.writeFeedback(x, forFilename: "")
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
            inDomains domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return rootPaths
    }

    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        self.fileExistsCallCount += 1
        return self.fileExistsResponse
    }

    func createDirectory(
            atPath path: String,
            withIntermediateDirectories createIntermediates: Bool,
            attributes: [FileAttributeKey: Any]? = nil) throws {
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
