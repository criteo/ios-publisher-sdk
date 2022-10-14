//
//  File.swift
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

class CR_FeedbackSerializerTests: XCTestCase {

  var serializer: CR_FeedbacksSerializer = CR_FeedbacksSerializer()
  var config: CR_Config = CR_Config(criteoPublisherId: "publisherId")
  let profileId = NSNumber(value: 42)

  func testConfigValuesPassed() {
    let body =
      self.serializer.postBody(forCsm: [], config: config, profileId: profileId) as NSDictionary

    XCTAssertEqual(body["wrapper_version"] as? String, config.sdkVersion)
    XCTAssertEqual(body["profile_id"] as? NSNumber, profileId)
  }

  func testMessagesCount() {
    let messages = [CR_FeedbackMessage(), CR_FeedbackMessage(), CR_FeedbackMessage()]
    let body = self.serializer.postBody(forCsm: messages, config: config, profileId: profileId) as NSDictionary
    let feedbacks = body["feedbacks"] as? NSArray
    XCTAssertEqual(feedbacks?.count, messages.count)
  }

  func testFilledMessage() {
    let cdbStartTimeStamp = 123123
    let cdbCallDuration = 10
    let bidConsumedDuration = 20
    let message = CR_FeedbackMessage()
    message.isTimeout = true
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
    message.zoneId = 42

    let feedback = serializeSingleMessage(message: message)
    let slots = feedback["slots"] as? NSArray
    let firstSlot = slots?.firstObject as? NSDictionary

    XCTAssertEqual(firstSlot?["cachedBidUsed"] as? Bool, true)
    XCTAssertEqual(firstSlot?["impressionId"] as? String, impressionId)
    XCTAssertEqual(firstSlot?["zoneId"] as? Int, 42)
  }

  func testEmptyMessage_SlotPart() {
    let feedback = serializeSingleMessage(message: CR_FeedbackMessage())
    let slots = feedback["slots"] as? NSArray
    let firstSlot = slots?.firstObject as? NSDictionary

    XCTAssertEqual(firstSlot?["cachedBidUsed"] as? Bool, false)
    XCTAssertNil(firstSlot?["impressionId"] as? String)
    XCTAssertNil(firstSlot?["zoneId"] as? Int)
  }

  private func serializeSingleMessage(message: CR_FeedbackMessage) -> NSDictionary {
    let body = self.serializer.postBody(forCsm: [message], config: config, profileId: profileId)
    let feedbacks = body["feedbacks"] as? NSArray
    do {
      let firstFeedback = try XCTUnwrap(feedbacks?.firstObject as? NSDictionary)
      return firstFeedback
    } catch {
      XCTFail("Failed to extract first feedback!")
    }
    return NSDictionary()
  }
}
