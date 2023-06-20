//
//  CRMRAIDUtils.swift
//  CriteoPublisherSdk
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
public class CRMRAIDUtils: NSObject {
  private enum Constants {
    static let fileName = "criteo-mraid"
    static let fileExtension = "js"
    static let bundle = "CriteoMRAIDResource"
    static let bundleExtension = "bundle"
    static let script = "<script type=\"text/javascript\">%@</script>"
    static let scriptInjectTarget = "<body>"
    static let testBundle = "CriteoPublisherSdkTests"
    static let testBundleExtension = "xctest"
  }

  @objc
  public static func loadMraid(from bundle: Bundle?) -> String? {
    guard
      let mraidURL = bundle?.url(
        forResource: Constants.fileName,
        withExtension: Constants.fileExtension)
    else {
      return nil
    }

    return try? String(contentsOf: mraidURL, encoding: .utf8)
  }

  @objc
  public static func build(html: String, from bundle: Bundle?) -> String {
    var mraidHTML = html
    guard
      let bodyRange = mraidHTML.range(of: Constants.scriptInjectTarget),
      let mraid = CRMRAIDUtils.loadMraid(from: bundle)
    else {
      return mraidHTML
    }

    let script = String(format: Constants.script, mraid)
    mraidHTML.insert(contentsOf: script, at: bodyRange.upperBound)
    return mraidHTML
  }

  @objc
  public static func mraidResourceBundle() -> Bundle? {
    guard
      let path = Bundle.main.path(forResource: Constants.bundle, ofType: Constants.bundleExtension)
    else {
      return nil
    }
    return Bundle(path: path)
  }

  @objc
  public static func mraidTestResourceBundle() -> Bundle? {
    return Bundle.allBundles.first(where: { $0.bundlePath.contains(Constants.testBundle) })
  }
}
