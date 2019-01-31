//
//  NSString+UrlEncoder.m
//  pubsdk
//
//  Created by Paul Davis on 1/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSString+UrlEncoder.h"

static NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
static NSCharacterSet *allowedCharacters = nil;

@implementation NSString (UrlEncoder)

- (NSString*) urlEncode
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    });

    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];

    return encodedString;
}

@end
