//
//  MRAIDURLHandler.swift
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
import SafariServices

@objc
public protocol CRExternalURLOpener {
  func open(url: URL)
}

public protocol MRAIDURLHandler {
  func handle(data: Data)
}

private struct MRAIDOpenURLAction: Decodable {
  let url: String
}

public final class CRMRAIDURLHandler: MRAIDURLHandler {
  private let logger: CRMRAIDLogger
  private let urlOpener: CRExternalURLOpener

  private var topViewController: UIViewController? {
    return UIApplication.shared.keyWindow?.rootViewController
  }

  public init(with logger: CRMRAIDLogger, urlOpener: CRExternalURLOpener) {
    self.logger = logger
    self.urlOpener = urlOpener
  }

  public func handle(data: Data) {
    do {
      let urlMessage = try JSONDecoder().decode(MRAIDOpenURLAction.self, from: data)
      guard let url = URL(string: urlMessage.url) else {
        logger.mraidLog(
          error: "Could not create an URL with given string representation: \(urlMessage.url)")
        return
      }
      urlOpener.open(url: url)
    } catch {
      logger.mraidLog(error: error.localizedDescription)
    }
  }
}
