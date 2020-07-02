//
//  CR_GdprSerializer.m
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

#import "CR_ApiQueryKeys.h"
#import "CR_Gdpr.h"
#import "CR_GdprSerializer.h"

@implementation CR_GdprSerializer

- (nullable NSDictionary<NSString *, NSObject *> *)dictionaryForGdpr:(CR_Gdpr *)gdpr {
  if (gdpr.tcfVersion == CR_GdprTcfVersionUnknown) {
    return nil;
  }
  NSMutableDictionary<NSString *, NSObject *> *gdprDict = [NSMutableDictionary new];
  gdprDict[CR_ApiQueryKeys.gdprConsentData] = gdpr.consentString;
  gdprDict[CR_ApiQueryKeys.gdprApplies] = gdpr.applies;
  gdprDict[CR_ApiQueryKeys.gdprVersion] = [self numberForTcfVersion:gdpr.tcfVersion];
  return gdprDict;
}

#pragma mark - Private

- (NSNumber *)numberForTcfVersion:(CR_GdprTcfVersion)version {
  switch (version) {
    case CR_GdprTcfVersionUnknown:
      return nil;
    case CR_GdprTcfVersion1_1:
      return @1;
    case CR_GdprTcfVersion2_0:
      return @2;
  }
}

@end
