//
//  CR_Ccpa.m
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

#import "CR_Ccpa.h"

/**
 Public spec for CCPA:
 https://iabtechlab.com/wp-content/uploads/2019/11/U.S.-Privacy-String-v1.0-IAB-Tech-Lab.pdf
 Internal spec for CCPA: https://go.crto.in/publisher-sdk-ccpa
*/

NSString *const CR_CcpaIabConsentStringKey = @"IABUSPrivacy_String";
NSString *const CR_CcpaCriteoStateKey = @"CriteoUSPrivacy_Bool";

@interface CR_Ccpa ()

@property(class, nonatomic, strong, readonly) NSArray<NSString *> *iabConsentOptInStrings;

@property(nonatomic, strong, readonly) NSUserDefaults *userDefaults;
@property(nonatomic, assign, readonly) BOOL isOptInByCriteoFormat;
@property(nonatomic, assign, readonly) BOOL isOptInByIabFormat;
@property(nonatomic, assign, readonly) BOOL isIabConsentStringValid;
@property(nonatomic, assign, readonly) BOOL isIabConsentStringOptIn;

@end

@implementation CR_Ccpa

#pragma mark - Class method

+ (NSArray<NSString *> *)iabConsentOptInStrings {
  return @[ @"1YNN", @"1YNY", @"1---", @"1YN-", @"1-N-" ];
}

#pragma mark - Object life cycle

- (instancetype)init {
  return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  if (self = [super init]) {
    _userDefaults = userDefaults;
  }
  return self;
}

#pragma mark - Public API

- (NSString *)iabConsentString {
  return [self.userDefaults stringForKey:CR_CcpaIabConsentStringKey];
}

- (void)setCriteoState:(CR_CcpaCriteoState)criteoState {
  [self.userDefaults setInteger:criteoState forKey:CR_CcpaCriteoStateKey];
}

- (CR_CcpaCriteoState)criteoState {
  return [self.userDefaults integerForKey:CR_CcpaCriteoStateKey];
}

- (BOOL)isOptIn {
  if (self.iabConsentString.length > 0) {
    return self.isOptInByIabFormat;
  }
  return self.isOptInByCriteoFormat;
}

#pragma mark - Private

- (BOOL)isOptInByCriteoFormat {
  return (self.criteoState == CR_CcpaCriteoStateOptIn) ||
         (self.criteoState == CR_CcpaCriteoStateUnset);
}

- (BOOL)isOptInByIabFormat {
  // if the iab consent isn't valid, we opt in.
  return !self.isIabConsentStringValid || self.isIabConsentStringOptIn;
}

- (BOOL)isIabConsentStringOptIn {
  NSString *consentString = [self.iabConsentString uppercaseString];
  if (consentString.length == 0) return YES;
  return [self.class.iabConsentOptInStrings containsObject:consentString];
}

- (BOOL)isIabConsentStringValid {
  NSString *consentString = [self.iabConsentString uppercaseString];
  if (consentString.length == 0) return YES;

  NSError *error = NULL;
  NSString *pattern = @"1(Y|N|-){3}";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:0
                                                                           error:&error];
  NSAssert(!error, @"Error occurred for the given regexp %@: %@", pattern, error);
  if (error) return NO;

  const NSRange range = NSMakeRange(0, [consentString length]);
  NSArray *matches = [regex matchesInString:consentString options:0 range:range];

  const BOOL result = (matches.count == 1);
  return result;
}

@end
