//
//  CR_FeedbackMessageTests.swift
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 20/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

import Foundation
import XCTest

class CR_FeedbackMessageTests : XCTestCase {

    func testEmptyObjectsEqualtyAndHash() {
        assertTwoMessagesObjectAndHashEquality(a: CR_FeedbackMessage(),
                                               b: CR_FeedbackMessage())
    }

    func testParticularlyFilledObjectsEqualtyAndHash() {
        assertTwoMessagesObjectAndHashEquality(a: createPartialFilledFeedbackMessage(),
                                               b: createPartialFilledFeedbackMessage())
    }

    func testFullyFilledObjectsEqualtyAndHash() {
        assertTwoMessagesObjectAndHashEquality(a: createFullyFilledFeedbackMessage(),
                                               b: createFullyFilledFeedbackMessage())
    }

    func testEmptyObjectsEqualityAfterEncodingAndDecoding() {
        assertMessageEqualityAfterEncodingAndDecoding(message: CR_FeedbackMessage())
    }

    func testParticularlyFilledObjectsAreEqual() {
        assertMessageEqualityAfterEncodingAndDecoding(message: createPartialFilledFeedbackMessage())
    }

    func testFullyFilledObjectsAreEqual() {
        assertMessageEqualityAfterEncodingAndDecoding(message: createFullyFilledFeedbackMessage())
    }

    private func createPartialFilledFeedbackMessage() -> CR_FeedbackMessage {
        let result = CR_FeedbackMessage()
        result.cdbCallStartTimestamp = 100
        result.isTimeouted = true
        return result
    }

    private func createFullyFilledFeedbackMessage() -> CR_FeedbackMessage {
        let result = CR_FeedbackMessage()
        result.impressionId = "impression id value";
        result.cdbCallStartTimestamp = 100;
        result.cdbCallEndTimestamp = 200;
        result.elapsedTimestamp = 300;
        result.isTimeouted = true;
        result.isExpired = true;
        return result
    }

    private func assertTwoMessagesObjectAndHashEquality(a: CR_FeedbackMessage, b: CR_FeedbackMessage, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(a, b, file: file, line: line)
        XCTAssertTrue(a.hash == b.hash, file: file, line: line);
    }

    private func assertMessageEqualityAfterEncodingAndDecoding(message: CR_FeedbackMessage, file: StaticString = #file, line: UInt = #line) {
        if #available(iOS 11.0, *) {
            let newMessage = try? self.archiveAndUnarchive(message: message)
            XCTAssertNotNil(newMessage, "new message is nil", file: file, line: line)
            XCTAssertEqual(message, newMessage, "messages are different", file: file, line: line)
        }

        let newObsoleteMessage = self.archiveAndUnarchiveObsoleteWay(message: message)
        XCTAssertEqual(message, newObsoleteMessage, "messages are different 2", file: file, line: line)
    }

    @available(iOS 11.0, *)
    private func archiveAndUnarchive(message: CR_FeedbackMessage) throws -> CR_FeedbackMessage? {
        let data = try NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: true)
        return try NSKeyedUnarchiver.unarchivedObject(ofClass: CR_FeedbackMessage.self, from: data)
    }

    private func archiveAndUnarchiveObsoleteWay(message: CR_FeedbackMessage) -> CR_FeedbackMessage {
        let data = NSKeyedArchiver.archivedData(withRootObject: message)
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! CR_FeedbackMessage
    }
}
