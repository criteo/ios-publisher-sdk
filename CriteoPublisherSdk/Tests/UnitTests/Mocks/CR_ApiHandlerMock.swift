//
//  CR_ApiHandlerMock.swift
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

import CriteoPublisherSdk

class CR_ApiHandlerMock: CR_ApiHandler {

  // MARK: - Life Cycle

  convenience init(dependencyProvider: CR_DependencyProvider) {
    self.init(
      networkManager: dependencyProvider.networkManager,
      threadManager: dependencyProvider.threadManager,
      integrationRegistry: dependencyProvider.integrationRegistry,
      userDataHolder: dependencyProvider.userDataHolder,
      internalContextProvider: dependencyProvider.internalContextProvider)
  }

  // MARK: - Overrides

  var callCdbWasCalled = false
  var callCdbAdUnits: [CR_CacheAdUnit]?
  var callCdbBeforeCdbResponseBlock: (() -> Void)?
  var callCdbCdbResponse: CR_CdbResponse?

  override func callCdb(
    _ adUnits: [CR_CacheAdUnit]!, consent: CR_DataProtectionConsent!, config: CR_Config!,
    deviceInfo: CR_DeviceInfo!, context contextData: CRContextData!,
    childDirectedTreatment: NSNumber!, beforeCdbCall: CR_BeforeCdbCall!,
    completionHandler: CR_CdbCompletionHandler!
  ) {
    callCdbWasCalled = true
    callCdbAdUnits = adUnits
    callCdbBeforeCdbResponseBlock?()
    completionHandler?(nil, callCdbCdbResponse, nil)
  }
}

// MARK: - MockProtocol

extension CR_ApiHandlerMock: MockProtocol {

  func reset() {
    callCdbWasCalled = false
    callCdbAdUnits = nil
    callCdbBeforeCdbResponseBlock = nil
    callCdbCdbResponse = nil
  }
}
