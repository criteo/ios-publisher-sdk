//
//  MRAIDLogHandler.swift
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
public protocol CRMRAIDLogger {
  func mraidLog(error: String)
  func mraidLog(warning: String)
  func mraidLog(debug: String)
  func mraidLog(info: String)
}

typealias MRAIDMessage = [String: String]

@objc
public class MRAIDLogHandler: NSObject {
  private let logger: CRMRAIDLogger

  public init(criteoLogger: CRMRAIDLogger) {
    logger = criteoLogger
  }

  func handle(log: MRAIDLog) {
    switch log.logLevel {
    case .error: logger.mraidLog(error: log.message)
    case .warning: logger.mraidLog(warning: log.message)
    case .debug: logger.mraidLog(debug: log.message)
    case .info: logger.mraidLog(info: log.message)
    }
  }

  func handle(data: Data) {
    do {
      let log = try JSONDecoder().decode(MRAIDLog.self, from: data)
      handle(log: log)
    } catch {
      logger.mraidLog(error: error.localizedDescription)
    }
  }
}
