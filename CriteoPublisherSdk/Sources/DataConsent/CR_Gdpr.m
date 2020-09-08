//
//  CR_Gdpr.m
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

#import "CR_Gdpr.h"
#import "CR_GdprVersion.h"

@interface CR_Gdpr ()

@property(strong, nonatomic, readonly) id<CR_GdprVersion> noGdpr;
@property(copy, nonatomic, readonly) NSArray<id<CR_GdprVersion>> *sortedVersions;
@property(strong, nonatomic, readonly) id<CR_GdprVersion> selectedVersion;

@end

@implementation CR_Gdpr

#pragma mark - Lifecycle

- (instancetype)init {
  return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  if (self = [super init]) {
    _noGdpr = [[CR_NoGdpr alloc] init];
    _sortedVersions = @[
      [CR_GdprVersionWithKeys gdprTcf2_0WithUserDefaults:userDefaults],
      [CR_GdprVersionWithKeys gdprTcf1_1WithUserDefaults:userDefaults]
    ];
  }
  return self;
}

#pragma mark - Custom Accessors

- (CR_GdprTcfVersion)tcfVersion {
  return self.selectedVersion.tcfVersion;
}

- (NSString *)consentString {
  return self.selectedVersion.consentString;
}

- (NSNumber *)applies {
  return self.selectedVersion.applies;
}

#pragma mark - Private

- (id<CR_GdprVersion>)selectedVersion {
  for (id<CR_GdprVersion> version in self.sortedVersions) {
    if (version.isValid) {
      return version;
    }
  }
  return self.noGdpr;
}

#pragma mark - NSObject

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, tcfVersion: %ld, isApplied: %@, consentString: %@>",
                                    NSStringFromClass(self.class), self, (long)self.tcfVersion,
                                    self.applies, self.consentString];
}

@end
