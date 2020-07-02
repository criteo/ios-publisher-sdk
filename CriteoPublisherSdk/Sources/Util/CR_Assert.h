//
//  CR_Assert.h
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

#ifndef CR_Assert_h
#define CR_Assert_h

#import "Logging.h"

/** Handle the Release mode that remove the NSAsserts */
#define CR_Assert(condition, desc, ...)       \
  do {                                        \
    NSAssert(condition, desc, ##__VA_ARGS__); \
    if (!condition) {                         \
      CLog(desc, ##__VA_ARGS__);              \
    }                                         \
  } while (0)

#endif /* CR_Assert_h */
