//
//  MRAIDHandlerTests.swift
//  CriteoPublisherSdkTests
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

import XCTest
import CriteoPublisherSdk
import WebKit

final class MRAIDHandlerTests: XCTestCase {
    func testOpenAction() {
        let webView = WKWebView()
        let logger = MRAIDLoggerMock()
        let urlOpener = URLOpenerMock() { url in

        }

        let mraidHandler = CRMRAIDHandler(with: webView, criteoLogger: logger, urlOpener: urlOpener, delegate: nil)
//        webView.evaluateJavaScript()

//        NSBundle *mraidBundle = [self mraidBundle];
//        NSString *mraid = [CRMRAIDUtils loadMraidFromBundle:mraidBundle];
//        NSString *html = @"<html><head></head><body></body></html>";
//        html = [CRMRAIDUtils insertMraid:html fromBundle:mraidBundle];
//        XCTAssertTrue([html containsString:mraid]);
    }
}
