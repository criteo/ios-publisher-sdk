//
//  CR_FeedbackMessage.m
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

#import "CR_FeedbackMessage.h"

@implementation CR_FeedbackMessage

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
  [coder encodeObject:self.profileId forKey:@"profileId"];
  [coder encodeObject:self.impressionId forKey:@"impressionId"];
  [coder encodeObject:self.requestGroupId forKey:@"requestGroupId"];
  [coder encodeObject:self.zoneId forKey:@"zoneId"];
  [coder encodeObject:self.cdbCallStartTimestamp forKey:@"cdbCallStartTimestamp"];
  [coder encodeObject:self.cdbCallEndTimestamp forKey:@"cdbCallEndTimestamp"];
  [coder encodeObject:self.elapsedTimestamp forKey:@"elapsedTimestamp"];
  [coder encodeBool:self.timeout forKey:@"timeout"];
  [coder encodeBool:self.expired forKey:@"expired"];
  [coder encodeBool:self.cachedBidUsed forKey:@"cachedBidUsed"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
  if (self = [super init]) {
    self.profileId = [coder decodeObjectOfClass:NSNumber.class forKey:@"profileId"];
    self.impressionId = [coder decodeObjectOfClass:NSString.class forKey:@"impressionId"];
    self.requestGroupId = [coder decodeObjectOfClass:NSString.class forKey:@"requestGroupId"];
    self.zoneId = [coder decodeObjectOfClass:NSString.class forKey:@"zoneId"];
    self.cdbCallStartTimestamp =
        [coder decodeObjectOfClass:NSNumber.class forKey:@"cdbCallStartTimestamp"];
    self.cdbCallEndTimestamp =
        [coder decodeObjectOfClass:NSNumber.class forKey:@"cdbCallEndTimestamp"];
    self.elapsedTimestamp = [coder decodeObjectOfClass:NSNumber.class forKey:@"elapsedTimestamp"];
    self.timeout = [coder decodeBoolForKey:@"timeout"];
    self.expired = [coder decodeBoolForKey:@"expired"];
    self.cachedBidUsed = [coder decodeBoolForKey:@"cachedBidUsed"];
  }
  return self;
}

- (NSString *)description {
  return [NSString
      stringWithFormat:@"{\n\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@}",
                       [NSString stringWithFormat:@"profileId: %@\n", self.profileId],
                       [NSString stringWithFormat:@"impressionId: %@\n", self.impressionId],
                       [NSString stringWithFormat:@"requestGroupId: %@\n", self.requestGroupId],
                       [NSString stringWithFormat:@"zoneId: %@\n", self.zoneId],
                       [NSString stringWithFormat:@"cdbCallStartTimestamp: %@\n",
                                                  self.cdbCallStartTimestamp],
                       [NSString
                           stringWithFormat:@"cdbCallEndTimestamp: %@\n", self.cdbCallEndTimestamp],
                       [NSString stringWithFormat:@"elapsedTimestamp: %@\n", self.elapsedTimestamp],
                       [NSString stringWithFormat:@"timeout: %@\n", @(self.timeout)],
                       [NSString stringWithFormat:@"expired: %@\n", @(self.expired)],
                       [NSString stringWithFormat:@"cachedBidUsed: %@\n", @(self.cachedBidUsed)]];
}

- (BOOL)isReadyToSend {
  return self.elapsedTimestamp != nil || self.expired || self.timeout;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

#pragma mark - Equality methods

- (BOOL)isEqualToFeedbackMessage:(CR_FeedbackMessage *)other {
  BOOL proIdEq =
      (self.profileId == nil && other.profileId == nil) ||
      (self.profileId && other.profileId && [self.profileId isEqualToNumber:other.profileId]);

  BOOL impIdEq = (!self.impressionId && !other.impressionId) ||
                 (self.impressionId && other.impressionId &&
                  [self.impressionId isEqualToString:other.impressionId]);

  BOOL grpIdEq = (!self.requestGroupId && !other.requestGroupId) ||
                 (self.requestGroupId && other.requestGroupId &&
                  [self.requestGroupId isEqualToString:other.requestGroupId]);

  BOOL zoneIdEq = (self.zoneId == nil && other.zoneId == nil) ||
                  (self.zoneId && other.zoneId && [self.zoneId isEqualToNumber:other.zoneId]);

  BOOL cdbStEq = (self.cdbCallStartTimestamp == nil && other.cdbCallStartTimestamp == nil) ||
                 (self.cdbCallStartTimestamp && other.cdbCallStartTimestamp &&
                  [self.cdbCallStartTimestamp isEqualToNumber:other.cdbCallStartTimestamp]);

  BOOL cdbEndEq = (self.cdbCallEndTimestamp == nil && other.cdbCallEndTimestamp == nil) ||
                  (self.cdbCallEndTimestamp && other.cdbCallEndTimestamp &&
                   [self.cdbCallEndTimestamp isEqualToNumber:other.cdbCallEndTimestamp]);

  BOOL elpTimeEq = (self.elapsedTimestamp == nil && other.elapsedTimestamp == nil) ||
                   (self.elapsedTimestamp && other.elapsedTimestamp &&
                    [self.elapsedTimestamp isEqualToNumber:other.elapsedTimestamp]);

  return proIdEq && impIdEq && grpIdEq && cdbStEq && cdbEndEq && elpTimeEq && zoneIdEq &&
         self.timeout == other.timeout && self.expired == other.expired &&
         self.cachedBidUsed == other.cachedBidUsed;
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }

  if (![object isKindOfClass:[CR_FeedbackMessage class]]) {
    return NO;
  }

  return [self isEqualToFeedbackMessage:object];
}

- (NSUInteger)hash {
  NSUInteger timeoutHash = [@(self.timeout) unsignedIntegerValue];
  NSUInteger expiredHash = [@(self.expired) unsignedIntegerValue];
  NSUInteger cachedBidUsed = [@(self.cachedBidUsed) unsignedIntegerValue];
  return [self.impressionId hash] << 1 ^ [self.requestGroupId hash] << 2 ^
         [self.cdbCallStartTimestamp hash] << 3 ^ [self.cdbCallEndTimestamp hash] << 4 ^
         [self.elapsedTimestamp hash] << 5 ^ expiredHash << 6 ^ timeoutHash << 7 ^
         cachedBidUsed << 8 ^ [self.profileId hash] << 9 ^ [self.zoneId hash] << 10;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
  CR_FeedbackMessage *m = [[CR_FeedbackMessage allocWithZone:zone] init];
  m.profileId = self.profileId;
  m.impressionId = self.impressionId;
  m.requestGroupId = self.requestGroupId;
  m.zoneId = self.zoneId;
  m.cdbCallStartTimestamp = self.cdbCallStartTimestamp;
  m.cdbCallEndTimestamp = self.cdbCallEndTimestamp;
  m.elapsedTimestamp = self.elapsedTimestamp;
  m.timeout = self.timeout;
  m.expired = self.expired;
  m.cachedBidUsed = self.cachedBidUsed;
  return m;
}

@end
