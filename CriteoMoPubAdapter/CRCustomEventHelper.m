//
//  CRCustomEventHelper.m
//  CriteoMoPubAdapter
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRCustomEventHelper.h"

NSString * const cpId = @"cpId";
NSString * const adUnitId = @"adUnitId";

@implementation CRCustomEventHelper

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
