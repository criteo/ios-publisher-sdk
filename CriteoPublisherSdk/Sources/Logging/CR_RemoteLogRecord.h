//
//  CR_RemoteLogRecord.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2021 Criteo. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "CR_Logging.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_RemoteLogRecord : NSObject <NSSecureCoding>

// TODO add: version, bundleId, deviceId, sessionId, profileId
@property(nonatomic, readonly, copy) NSString *tag;
@property(nonatomic, readonly, assign) CR_LogSeverity severity;
@property(nonatomic, readonly, copy) NSString *message;
@property(nonatomic, readonly, copy, nullable) NSString *exceptionType;

- (instancetype)initWithTag:(NSString *)tag
                   severity:(CR_LogSeverity)severity
                    message:(NSString *)message
              exceptionType:(NSString *_Nullable)exceptionType;

@end

NS_ASSUME_NONNULL_END
