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
  func didReceivePlayVideoAction(with url: String)
}

private class MRAIDJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}

public struct MRAIDMessageHandler {
  private let decoder = MRAIDJSONDecoder()
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
      let actionMessage = try decoder.decode(MRAIDActionMessage.self, from: data)
      switch actionMessage.action {
      case .log: logHandler.handle(data: data)
      case .open: urlHandler.handle(data: data)
      case .expand: handleExpand(message: data)
      case .close: delegate?.didReceiveCloseAction()
      case .playVideo: handlePlayVideo(message: data)
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
fileprivate extension MRAIDMessageHandler {
  func handleExpand(message data: Data) {
    do {
      let expandMessage = try decoder.decode(MRAIDExpandMessage.self, from: data)
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

    func handlePlayVideo(message data: Data) {
        do {
            let playVideoMessage = try decoder.decode(MRAIDPlayVideoMessage.self, from: data)
            delegate?.didReceivePlayVideoAction(with: playVideoMessage.url)
        } catch {
            logHandler.handle(
              log: .init(
                logId: nil,
                message: error.localizedDescription,
                logLevel: .error,
                action: .playVideo))
          }
    }
}
