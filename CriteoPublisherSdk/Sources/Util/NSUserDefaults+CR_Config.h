//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef NSUserDefaults_CR_Config_H
#define NSUserDefaults_CR_Config_H

#import <Foundation/Foundation.h>

@interface NSUserDefaults (CR_Config)

- (BOOL)cr_valueForKillSwitch;

- (void)cr_setValueForKillSwitch:(BOOL)killSwitch;

- (BOOL)cr_valueForCsmFeatureFlag;

- (void)cr_setValueForCsmFeatureFlag:(BOOL)csmFeatureFlag;

@end

#endif /* NSUserDefaults_CR_Config_H */
