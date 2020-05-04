//
//  CR_UniqueIdGeneratorTests.swift
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

import Foundation
import XCTest

class CR_UniqueIdGeneratorTests: XCTestCase {
    func test_generateId_GivenDeterministicInputFromCdb() {
        let uuid = UUID(uuidString: "c60e5638-ce73-4c42-a7a1-33c2fff509e4")!
        let timestamp: TimeInterval = 1234567890
        let id = CR_UniqueIdGenerator.generateId(with: uuid, timestamp: timestamp)

        XCTAssertEqual(id, "499602d2ce73cc4267a133c2fff509e4")
    }

    func test_generateId_AreUnique() {
        for _ in 0..<1000 {
            let expectedSize = 1000
            let ids = (0..<expectedSize).map { _ in
                CR_UniqueIdGenerator.generateId()
            }
            XCTAssertEqual(Set(ids).count, expectedSize)
        }
    }
}
