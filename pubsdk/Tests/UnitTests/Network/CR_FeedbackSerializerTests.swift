//
//  File.swift
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 26/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

import Foundation
import XCTest

class CR_FeedbackSerializerTests: XCTestCase {

    var serializer: CR_FeedbacksSerializer = CR_FeedbacksSerializer()
    var config: CR_Config = CR_Config(criteoPublisherId: "publisherId")

    func testConfigValuesPassed() {
        let body = self.serializer.postBody(forCsm: [], config: config) as NSDictionary;

        XCTAssertEqual(body["wrapper_version"] as? String, config.sdkVersion)
        XCTAssertEqual(body["profile_id"] as? NSNumber, config.profileId)
    }

    func testMessagesCount() {
        let messages = [
            CR_FeedbackMessage(),
            CR_FeedbackMessage(),
            CR_FeedbackMessage()
        ]
        let body = self.serializer.postBody(forCsm: messages, config: config) as NSDictionary;
        let feedbacks = body["feedbacks"] as? NSArray
        XCTAssertEqual(feedbacks?.count, messages.count)
    }

    func testFilledMessage() {
        let cdbStartTimeStamp = 123123
        let cdbCallDuration = 10
        let bidConsumedDuration = 20
        let message = CR_FeedbackMessage();
        message.isTimeout = true;
        message.cdbCallStartTimestamp = NSNumber(value: cdbStartTimeStamp)
        message.cdbCallEndTimestamp = NSNumber(value: cdbStartTimeStamp + cdbCallDuration)
        message.elapsedTimestamp = NSNumber(value: cdbStartTimeStamp + bidConsumedDuration)

        let feedback = serializeSingleMessage(message: message)

        XCTAssertEqual(feedback["isTimeout"] as? Bool, true)
        XCTAssertEqual(feedback["cdbCallStartElapsed"] as? Int, 0)
        XCTAssertEqual(feedback["cdbCallEndElapsed"] as? Int, cdbCallDuration)
        XCTAssertEqual(feedback["elapsed"] as? Int, bidConsumedDuration)

    }

    func testEmptyMessage() {
        let feedback = serializeSingleMessage(message: CR_FeedbackMessage())

        XCTAssertEqual(feedback["isTimeout"] as? Bool, false)
        XCTAssertEqual(feedback["cdbCallStartElapsed"] as? Int, 0)
        XCTAssertNil(feedback["cdbCallEndElapsed"] as? Int)
        XCTAssertNil(feedback["elapsed"] as? Int)
    }

    func testAnyMessageContainsSlotsField() {
        let feedback = serializeSingleMessage(message: CR_FeedbackMessage())
        let slots = feedback["slots"] as? NSArray

        XCTAssertNotNil(slots)
        XCTAssertEqual(slots?.count, 1)
    }

    func testFilledMessage_SlotPart() {
        let message = CR_FeedbackMessage()
        let impressionId = "impId123"
        message.impressionId = impressionId
        message.cachedBidUsed = true

        let feedback = serializeSingleMessage(message: message)
        let slot = (feedback["slots"] as! NSArray)[0] as! NSDictionary

        XCTAssertEqual(slot["cachedBidUsed"] as? Bool, true)
        XCTAssertEqual(slot["impressionId"] as? String, impressionId)
    }

    func testEmptyMessage_SlotPart() {
        let feedback = serializeSingleMessage(message: CR_FeedbackMessage())
        let slot = (feedback["slots"] as! NSArray)[0] as! NSDictionary

        XCTAssertEqual(slot["cachedBidUsed"] as? Bool, false)
        XCTAssertNil(slot["impressionId"] as? String)
    }

    private func serializeSingleMessage(message: CR_FeedbackMessage) -> NSDictionary {
        let body = self.serializer.postBody(forCsm: [message], config: config) as NSDictionary;
        let feedbacks = body["feedbacks"] as! NSArray
        let feedback = feedbacks[0] as! NSDictionary
        return feedback
    }
}
