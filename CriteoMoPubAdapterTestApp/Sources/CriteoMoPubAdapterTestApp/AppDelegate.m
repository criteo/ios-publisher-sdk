//
//  AppDelegate.m
//  CriteoMoPubAdapterTestApp
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "AppDelegate.h"
#import "MoPub.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  MPMoPubConfiguration *config = [[MPMoPubConfiguration alloc]
      initWithAdUnitIdForAppInitialization:@"5f6c4592630f4f96bc3106b6ed0cc3f1"];
  [[MoPub sharedInstance] initializeSdkWithConfiguration:config completion:nil];

  return YES;
}

@end
