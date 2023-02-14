//
//  MraidLoader.swift
//  CriteoAdViewer
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

struct MraidLoader {

  static func getHtmlWithMraidScriptTag() -> String {
    return load(mraid: "MraidScriptTag")
  }

  static func getHtmlWithDocumentWriteMraidScriptTag() -> String {
    return load(mraid: "MraidDocumentTag")
  }

  static func getHtmlWithoutMraidScript() -> String {
    return load(mraid: "NoMraidTag")
  }

  static func load(mraid file: String) -> String {
    let path = Bundle.main.path(forResource: file, ofType: "html") ?? "</>"
    return (try? String(contentsOfFile: path)) ?? "-"
  }
}
