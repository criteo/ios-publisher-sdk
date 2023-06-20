//
//  MRAIDMessaheHandler.swift
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

public protocol MRAIDMessageHandlerDelegate: AnyObject {
  func didReceive(expand action: MRAIDExpandMessage)
  func didReceiveCloseAction()
}

public struct MRAIDMessageHandler {
  private let logHandler: MRAIDLogHandler
  private let urlHandler: MRAIDURLHandler
  public weak var delegate: MRAIDMessageHandlerDelegate?

  public init(logHandler: MRAIDLogHandler, urlHandler: MRAIDURLHandler) {
    self.logHandler = logHandler
    self.urlHandler = urlHandler
  }

  public func handle(message: Any) {
    do {
      let data = try JSONSerialization.data(withJSONObject: message)
      let actionMessage = try JSONDecoder().decode(MRAIDActionMessage.self, from: data)
      switch actionMessage.action {
      case .log: logHandler.handle(data: data)
      case .open: urlHandler.handle(data: data)
      case .expand: handleExpand(message: data)
      case .close: delegate?.didReceiveCloseAction()
      case .none: break
      }
    } catch {
      logHandler.handle(
        log: .init(
          logId: nil,
          message: "Could not deserialise the action message from \(message)",
          logLevel: .error,
          action: .none))
    }
  }
}

// MARK: - Private methods
extension MRAIDMessageHandler {
  fileprivate func handleExpand(message data: Data) {
    do {
      let expandMessage = try JSONDecoder().decode(MRAIDExpandMessage.self, from: data)
      delegate?.didReceive(expand: expandMessage)
    } catch {
      logHandler.handle(
        log: .init(
          logId: nil,
          message: error.localizedDescription,
          logLevel: .error,
          action: .expand))
    }
  }
}
