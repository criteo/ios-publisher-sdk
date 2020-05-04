//
// Copyright (c) 2020 Criteo. All rights reserved.
//

#ifndef NSUserDefaults_CR_Config_H
#define NSUserDefaults_CR_Config_H

#import <Foundation/Foundation.h>

@interface NSUserDefaults (CR_Config)

- (BOOL)valueForKillSwitch;

- (void)setValueForKillSwitch:(BOOL)killSwitch;

- (BOOL)valueForCsmFeatureFlag;

- (void)setValueForCsmFeatureFlag:(BOOL)csmFeatureFlag;

@end

#endif /* NSUserDefaults_CR_Config_H */
