//
//  CR_FeedbackFileManagerTests.swift
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 24/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

import Foundation

import XCTest

class CR_FeedbackFileManagerTests: XCTestCase {

    var fileManipulatingMock: CR_DefaultFileManipulatingMock = CR_DefaultFileManipulatingMock()
    var feedbackFileManager: CR_FeedbackFileManager = CR_FeedbackFileManager(fileManipulating: CR_DefaultFileManipulator());

    override func setUp() {
        super.setUp()
        self.fileManipulatingMock = CR_DefaultFileManipulatingMock()
        self.feedbackFileManager = CR_FeedbackFileManager(fileManipulating: self.fileManipulatingMock)
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
        self.fileManipulatingMock.rootPaths = []
        let x = CR_FeedbackFileManager(fileManipulating: self.fileManipulatingMock) as CR_FeedbackFileManager?
        XCTAssertNil(x)
    }

    func testDirectoryExists_ShouldNotCallCreateDirectory() {
        let mock = CR_DefaultFileManipulatingMock()
        self.feedbackFileManager = CR_FeedbackFileManager(fileManipulating: mock)
        XCTAssertEqual(mock.createDirectoryCallCount, 0)
    }

    func testDirectoryNotExists_ShouldCallCreateDirectory() {
        let mock = CR_DefaultFileManipulatingMock()
        mock.fileExistsResponse = false
        self.feedbackFileManager = CR_FeedbackFileManager(fileManipulating: mock)
        XCTAssertEqual(mock.createDirectoryCallCount, 1)
    }

    private func now() -> NSNumber {
        return NSNumber(value: NSDate().timeIntervalSince1970)
    }
}

class CR_DefaultFileManipulatingMock: NSObject, CR_FileManipulating {

    var message : CR_FeedbackMessage?
    var contentOfDirectory : [String] = [];
    var rootPaths : [URL] = [URL(fileURLWithPath: "path/to/file")]
    var fileExistsCallCount : Int = 0
    var fileExistsResponse : Bool = true
    var createDirectoryCallCount : Int = 0

    func write(_ data: Data, forAbsolutePath path: String) {
        message = NSKeyedUnarchiver.unarchiveObject(with: data) as? CR_FeedbackMessage;
    }

    func readData(forAbsolutePath path: String) -> Data? {
        return message != nil ? NSKeyedArchiver.archivedData(withRootObject: message!) : nil
    }

    func urls(for directory: FileManager.SearchPathDirectory, inDomains domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return rootPaths
    }

    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        self.fileExistsCallCount += 1
        return self.fileExistsResponse
    }

    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        self.createDirectoryCallCount += 1
    }

    func removeItem(atPath path: String) throws {
        self.message = nil
    }

    func contentsOfDirectory(atPath path: String) throws -> [String] {
        return contentOfDirectory
    }
}
