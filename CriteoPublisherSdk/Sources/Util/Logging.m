//
//  Logging.m
//  CriteoPublisherSdk
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

#import "Logging.h"

void CLog_DoLog(const char *filename, int lineNum, const char *funcname, NSString *_Nonnull format,
                ...) {
  NSString *fNameStr = [NSString stringWithUTF8String:filename];

  NSURL *fNameUrl = [NSURL fileURLWithPath:[fNameStr stringByExpandingTildeInPath] isDirectory:NO];

  NSString *file = fNameUrl.lastPathComponent;

  va_list pList;
  va_start(pList, format);

  NSString *annotatedFormat = [NSString stringWithFormat:@"%@:%d %s ", file, lineNum, funcname];
  annotatedFormat = [annotatedFormat stringByAppendingString:format];

  NSLogv(annotatedFormat, pList);

  va_end(pList);
}

void CLog_DoLog_Dummy(NSString *_Nonnull format, ...) {}
