//
//  CR_BidManagerHelper.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_BidManagerHelper.h"

@implementation CR_BidManagerHelper

+ (void)removeCriteoBidsFromMoPubRequest:(id)adRequest {
    SEL mopubKeywords = NSSelectorFromString(@"keywords");
    if([adRequest respondsToSelector:mopubKeywords]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id keywords = [adRequest performSelector:mopubKeywords];
        if ([keywords isKindOfClass:[NSString class]]) {
            NSArray *keywordPairs = [keywords componentsSeparatedByString:@","];
            NSMutableArray *nonCriteoKeywords = [[NSMutableArray alloc] init];
            for (NSString *pair in keywordPairs) {
                if (![pair hasPrefix:@"crt_"]) {
                    [nonCriteoKeywords addObject:pair];
                }
            }
            keywords = [nonCriteoKeywords componentsJoinedByString:@","];
            [adRequest setValue:keywords forKey:@"keywords"];
        }
#pragma clang diagnostic pop
    }
}

@end
