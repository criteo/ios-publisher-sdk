//
//  CR_CustomEventHelper.m
//  CriteoMoPubAdapter
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_CustomEventHelper.h"

NSString * const cpId = @"cpId";
NSString * const adUnitId = @"adUnitId";

@implementation CR_CustomEventHelper

+ (BOOL) checkValidInfo:(NSDictionary *)info {
    if (info){
        if ([info[cpId] isKindOfClass:NSString.class] && [info[adUnitId] isKindOfClass:NSString.class]){
            if ([info[cpId] length] > 0 && [info[adUnitId] length] > 0){
                return YES;
            }
        }
    }
    return NO;
}

@end
