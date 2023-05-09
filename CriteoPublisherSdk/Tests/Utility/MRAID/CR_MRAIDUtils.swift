//
//  CR_MRAIDUtils.swift
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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

@objc
public class CR_MRAIDUtils: NSObject {
  @objc
  public static func mraidBundle() -> Bundle? {
    for bundle in Bundle.allBundles {
      if bundle.bundlePath.hasSuffix("xctest"),
        let path = bundle.path(forResource: "CriteoMRAIDResource", ofType: "bundle") {
        return Bundle.init(path: path)
      }
    }

    return nil
  }
}
