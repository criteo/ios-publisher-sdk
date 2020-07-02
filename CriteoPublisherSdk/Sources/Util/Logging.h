//
//  Logging.h
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

#ifndef Logging_h
#define Logging_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if (defined(DEBUG) || defined(CLOG_ENABLE_FOR_TESTING))
#define CLOG_ENABLE 1
#else
#define CLOG_ENABLE 0
#endif

#if (CLOG_ENABLE)

#define CLog(args...) CLog_DoLog(__FILE__, __LINE__, __PRETTY_FUNCTION__, args)
void CLog_DoLog(const char *filename, int lineNum, const char *funcname, NSString *fmt, ...);
#define CLogException(exception) \
  NSAssert(false, @"Exception occurred: %@, %@", exception, [exception userInfo]);

#else

#define CLog(args...) CLog_DoLog_Dummy(args)
void CLog_DoLog_Dummy(NSString* _Nonnull format, ...);
#define CLogException(exception) \
  do {                           \
  } while (0)

#endif

#define VERBOSE_LOGGING_ENABLE 0

#if (VERBOSE_LOGGING_ENABLE)
#define CLogInfo(args...) NSLog(args)
#define CLog(args...) NSLog(args)
#else
#define CLogInfo(args...) ((void)0)
#endif

NS_ASSUME_NONNULL_END

#endif /* Logging_h */
