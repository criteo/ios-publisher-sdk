//
//  CR_FeedbackMessageTests.swift
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

class CR_FeedbackMessageTests : XCTestCase {

    func testEmptyObjectsEqualityAndHash() {
        assertTwoMessagesObjectAndHashEquality(CR_FeedbackMessage(),
                                               CR_FeedbackMessage())
    }

    func testParticularlyFilledObjectsEqualityAndHash() {
        assertTwoMessagesObjectAndHashEquality(createPartialFilledFeedbackMessage(),
                                               createPartialFilledFeedbackMessage())
    }

    func testFullyFilledObjectsEqualityAndHash() {
        assertTwoMessagesObjectAndHashEquality(createFullyFilledFeedbackMessage(),
                                               createFullyFilledFeedbackMessage())
    }

    func testDifferentObjectsNotEqual() {
        XCTAssertNotEqual(createPartialFilledFeedbackMessage(), CR_FeedbackMessage())
    }

    func testDifferentObjectsNotEqual2() {
        XCTAssertNotEqual(CR_FeedbackMessage(), createPartialFilledFeedbackMessage())
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

    func testEmptyMessageIsNotReadyToSend() {
        XCTAssertFalse(CR_FeedbackMessage().isReadyToSend)
    }

    func testMessageWithElapsedTimeIsReadyToSend() {
        let message = CR_FeedbackMessage()
        message.elapsedTimestamp = 100
        XCTAssertTrue(message.isReadyToSend)
    }

    func testMessageWithTimeoutIsReadyToSend() {
        let message = CR_FeedbackMessage()
        message.isTimeout = true
        XCTAssertTrue(message.isReadyToSend)
    }

    func testExpiredMessageIsRTS() {
        let message = CR_FeedbackMessage()
        message.isExpired = true
        XCTAssertTrue(message.isReadyToSend)
    }

    private func createPartialFilledFeedbackMessage() -> CR_FeedbackMessage {
        let result = CR_FeedbackMessage()
        result.cdbCallStartTimestamp = 100
        result.isTimeout = true
        return result
    }

    private func createFullyFilledFeedbackMessage() -> CR_FeedbackMessage {
        let result = CR_FeedbackMessage()
        result.profileId = 42
        result.impressionId = "impression id value"
        result.cdbCallStartTimestamp = 100
        result.cdbCallEndTimestamp = 200
        result.elapsedTimestamp = 300
        result.isTimeout = true
        result.isExpired = true
        return result
    }

    private func assertTwoMessagesObjectAndHashEquality(_ a: CR_FeedbackMessage, _ b: CR_FeedbackMessage, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(a, b, file: file, line: line)
        XCTAssertTrue(a.hash == b.hash, file: file, line: line)
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
