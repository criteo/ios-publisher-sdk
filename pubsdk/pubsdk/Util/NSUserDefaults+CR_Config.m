//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSUserDefaults+CR_Config.h"

NSString *const NSUserDefaultsKillSwitchKey = @"CRITEO_KillSwitch";
NSString *const NSUserDefaultsCsmEnabledKey = @"CRITEO_CsmEnabled";

@implementation NSUserDefaults (CR_Config)

- (BOOL)cr_valueForKillSwitch {
  return [self boolForKey:NSUserDefaultsKillSwitchKey withDefaultValue:NO];
}

- (void)cr_setValueForKillSwitch:(BOOL)killSwitch {
  [self setBool:killSwitch forKey:NSUserDefaultsKillSwitchKey];
}

- (BOOL)cr_valueForCsmFeatureFlag {
  return [self boolForKey:NSUserDefaultsCsmEnabledKey withDefaultValue:YES];
}

- (void)cr_setValueForCsmFeatureFlag:(BOOL)csmFeatureFlag {
  [self setBool:csmFeatureFlag forKey:NSUserDefaultsCsmEnabledKey];
}

#pragma mark - Private

- (BOOL)boolForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue {
  id value = [self objectForKey:key];
  if (value && [value isKindOfClass:NSNumber.class]) {
    return ((NSNumber *)value).boolValue;
  }
  return defaultValue;
}

@end
