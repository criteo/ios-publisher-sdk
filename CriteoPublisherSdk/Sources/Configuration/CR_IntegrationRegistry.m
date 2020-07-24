//
//  CR_IntegrationRegistry.m
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

#import "CR_IntegrationRegistry.h"

@interface CR_IntegrationRegistry ()

@property(nonatomic, strong, readonly) NSUserDefaults *userDefaults;

@end

@implementation CR_IntegrationRegistry

- (instancetype)init {
  return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  if (self = [super init]) {
    _userDefaults = userDefaults;
  }
  return self;
}

- (void)declare:(CR_IntegrationType)integrationType {
  // TODO
}

- (NSNumber *)profileId {
  // TODO
  return @(CR_IntegrationFallback);
}

@end
