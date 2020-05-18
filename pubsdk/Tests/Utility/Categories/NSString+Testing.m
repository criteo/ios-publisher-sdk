//
//  NSString+Testing.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSString+Testing.h"

@implementation NSString (Testing)

- (NSUInteger)ocurrencesCountOfSubstring:(NSString *)substring {
    NSUInteger count = 0, length = [self length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound) {
        range = [self rangeOfString: substring options:0 range:range];
        if(range.location != NSNotFound) {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
    return count;
}

@end
