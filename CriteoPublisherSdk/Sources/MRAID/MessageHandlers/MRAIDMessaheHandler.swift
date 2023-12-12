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
    func didReceive(resize action: MRAIDResizeMessage)
    func didReceive(orientation properties: MRAIDOrientationPropertiesMessage)
}

class MRAIDJSONDecoder: JSONDecoder {
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
            case .close: delegate?.didReceiveCloseAction()
            case .expand: handleExpand(message: data, action: actionMessage.action)
            case .playVideo: handlePlayVideo(message: data, action: actionMessage.action)
            case .resize: handleResize(message: data, action: actionMessage.action)
            case .orientationPropertiesUpdate, .orientationPropertiesSet:
                handleOrientationPropertiesUpdate(message: data, action: actionMessage.action)
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
    func handleExpand(message data: Data, action: Action) {
        guard let expandMessage: MRAIDExpandMessage = extractMessage(from: data, action: action) else { return }
        delegate?.didReceive(expand: expandMessage)
    }

    func handlePlayVideo(message data: Data, action: Action) {
        guard let playVideoMessage: MRAIDPlayVideoMessage = extractMessage(from: data, action: action) else { return }
        delegate?.didReceivePlayVideoAction(with: playVideoMessage.url)
    }

    func handleResize(message data: Data, action: Action) {
        guard let resizeMessage: MRAIDResizeMessage = extractMessage(from: data, action: action) else { return }
            delegate?.didReceive(resize: resizeMessage)
    }

    func handleOrientationPropertiesUpdate(message data: Data, action: Action) {
        guard let message: MRAIDOrientationPropertiesMessage = extractMessage(from: data, action: action) else { return }
        delegate?.didReceive(orientation: message)
    }

    func extractMessage<T: Decodable>(from data: Data, action: Action) -> T? {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logHandler.handle(
                log: .init(
                    logId: nil,
                    message: error.localizedDescription,
                    logLevel: .error,
                    action: action))
        }
        return nil
    }
}
