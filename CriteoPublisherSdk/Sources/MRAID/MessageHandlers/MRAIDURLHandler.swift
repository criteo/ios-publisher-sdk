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

protocol MRAIDURLHandler {
    func open(url: URL)
    func handle(data: Data)
}

private struct MRAIDOpenURLAction: Decodable {
    let url: String
}

final class CRMRAIDURLHandler: MRAIDURLHandler {
    private let logger: CRMRAIDLogger
    private var topViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }

    init(with logger: CRMRAIDLogger) {
        self.logger = logger
    }

    func open(url: URL) {
        let config = SFSafariViewController.Configuration()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        guard let viewController = topViewController else {
            logger.mraidLog(error: "Top ViewController is nil, cannot present SFSafariViewController")
            return
        }
        viewController.present(safariViewController, animated: true)
    }

    func handle(data: Data) {
        do {
            let urlMessage = try JSONDecoder().decode(MRAIDOpenURLAction.self, from: data)
            guard let url = URL(string: urlMessage.url) else {
                logger.mraidLog(error: "Could not create an URL with given string representation")
                return
            }
            open(url: url)
        } catch {
            logger.mraidLog(error: error.localizedDescription)
        }
    }
}
