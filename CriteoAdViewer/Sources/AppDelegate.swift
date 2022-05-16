//
//  AppDelegate.swift
//  CriteoAdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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

import AppTrackingTransparency
import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        print("Tracking Authorization: \(status.rawValue)")
      })
      SKAdNetwork.registerAppForAdNetworkAttribution()
    }
    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: "IABConsent_SubjectToGDPR")
    userDefaults.removeObject(forKey: "IABConsent_ConsentString")
    userDefaults.removeObject(forKey: "IABConsent_ParsedVendorConsents")
  }

  func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
      let action = components.host,
      let queryItems = components.queryItems
    else {
      print("Invalid URL")
      return false
    }
    let parameters = Dictionary(uniqueKeysWithValues: queryItems.map({ ($0.name, $0.value) }))
    switch action {
    case "loadProduct":
      Criteo.loadProduct(
        withParameters: parameters as [AnyHashable: Any], from: window?.rootViewController)
    default: print("Invalid Action")
    }
    return false
  }
}
