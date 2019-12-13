//
//  NSString+CR_UrlEncoder.m
//  pubsdk
//
//  Created by Paul Davis on 1/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSString+CR_UrlEncoder.h"

static NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
static NSCharacterSet *allowedCharacters = nil;

@implementation NSString (CR_UrlEncoder)

- (NSString*) urlEncode
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    });

    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];

    return encodedString;
}

+ (NSString *)dfpCompatibleString:(NSString *)string
{
    NSString *dfpCompatibleString = nil;

    if(string) {
        NSData *encodedStringData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [encodedStringData base64EncodedStringWithOptions:0];
        dfpCompatibleString = [[base64String urlEncode] urlEncode];
    }

    return dfpCompatibleString;
}

+ (NSString *)decodeDfpCompatibleString:(NSString *)string
{
    NSString *decodedString = nil;

    if(string) {
        NSString *unescapedString = [[string stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:unescapedString options:0];
        decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    }

    return decodedString;
}

+ (NSString *)mopubCompatibleDisplayUrlForDisplayUrl:(NSString *)displayUrl
{
    return displayUrl;
}

@end
