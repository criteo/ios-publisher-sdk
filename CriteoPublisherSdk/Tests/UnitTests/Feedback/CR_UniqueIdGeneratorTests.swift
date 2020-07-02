//
//  CR_UniqueIdGeneratorTests.swift
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
