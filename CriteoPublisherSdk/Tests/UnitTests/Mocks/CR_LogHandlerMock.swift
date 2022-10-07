//
//  CR_LogHandlerMock.swift
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2022 Criteo. All rights reserved.
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


class CR_LogHandlerMock: NSObject {


  // MARK: - Overrides

  var logMessageWasCalled = false
  var logMessageWasCalledWithMessage: CR_LogMessage? = nil
}


// MARK: - CR_LogHandler

extension CR_LogHandlerMock: CR_LogHandler {

  var consoleLogHandler: CR_ConsoleLogHandler! {
    return CR_ConsoleLogHandler()
  }

  func logMessage(_ message: CR_LogMessage!) {
    logMessageWasCalled = true
    logMessageWasCalledWithMessage = message
  }
}


// MARK: - MockProtocol

extension CR_LogHandlerMock: MockProtocol {

  func reset() {

    logMessageWasCalled = false
    logMessageWasCalledWithMessage = nil
  }
}
