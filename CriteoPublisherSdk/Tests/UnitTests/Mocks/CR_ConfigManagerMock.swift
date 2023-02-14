//
//  CR_ConfigManagerMock.swift
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

class CR_ConfigManagerMock: CR_ConfigManager {

  // MARK: - Life Cycle

  convenience init(dependencyProvider: CR_DependencyProvider) {
    self.init(
      apiHandler: dependencyProvider.apiHandler,
      integrationRegistry: dependencyProvider.integrationRegistry,
      deviceInfo: dependencyProvider.deviceInfo)
  }

  // MARK: - Overrides

  var refreshConfigWasCalled = false

  override func refreshConfig(_ config: CR_Config) {
    refreshConfigWasCalled = true
    self.refreshConfig(config)
  }
}

// MARK: - MockProtocol

extension CR_ConfigManagerMock: MockProtocol {

  func reset() {

    refreshConfigWasCalled = false
  }
}
