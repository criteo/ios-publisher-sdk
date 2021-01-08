//
//  CR_RemoteLogRecord.m
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

#import "CR_RemoteLogRecord.h"

@implementation CR_RemoteLogRecord

- (instancetype)initWithVersion:(NSString *)version
                       bundleId:(NSString *)bundleId
                       deviceId:(NSString *)deviceId
                      sessionId:(NSString *)sessionId
                      profileId:(NSNumber *)profileId
                            tag:(NSString *)tag
                       severity:(CR_LogSeverity)severity
                        message:(NSString *)message
                  exceptionType:(NSString *_Nullable)exceptionType {
  self = [super init];
  if (self) {
    _version = version;
    _bundleId = bundleId;
    _deviceId = deviceId;
    _sessionId = sessionId;
    _profileId = profileId;
    _tag = tag;
    _severity = severity;
    _message = message;
    _exceptionType = exceptionType;
  }

  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self) {
    _version = [coder decodeObjectOfClass:NSString.class forKey:@"_version"];
    _bundleId = [coder decodeObjectOfClass:NSString.class forKey:@"_bundleId"];
    _deviceId = [coder decodeObjectOfClass:NSString.class forKey:@"_deviceId"];
    _sessionId = [coder decodeObjectOfClass:NSString.class forKey:@"_sessionId"];
    _profileId = [coder decodeObjectOfClass:NSNumber.class forKey:@"_profileId"];
    _tag = [coder decodeObjectOfClass:NSString.class forKey:@"_tag"];
    _severity = (CR_LogSeverity)[coder decodeIntForKey:@"_severity"];
    _message = [coder decodeObjectOfClass:NSString.class forKey:@"_message"];
    _exceptionType = [coder decodeObjectOfClass:NSString.class forKey:@"_exceptionType"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.version forKey:@"_version"];
  [coder encodeObject:self.bundleId forKey:@"_bundleId"];
  [coder encodeObject:self.deviceId forKey:@"_deviceId"];
  [coder encodeObject:self.sessionId forKey:@"_sessionId"];
  [coder encodeObject:self.profileId forKey:@"_profileId"];
  [coder encodeObject:self.tag forKey:@"_tag"];
  [coder encodeInt:(int)self.severity forKey:@"_severity"];
  [coder encodeObject:self.message forKey:@"_message"];
  [coder encodeObject:self.exceptionType forKey:@"_exceptionType"];
}

+ (BOOL)supportsSecureCoding {
  return YES;
}

@end