//
//  NSString+CR_Url.m
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSString+CR_Url.h"

static NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
static NSCharacterSet *allowedCharacters = nil;

@implementation NSString (CR_Url)

- (NSString *)urlEncode {
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

+ (NSString *)urlQueryParamsWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary {
    NSMutableArray<NSString *> *parts = [[NSMutableArray alloc] init];
    for(NSString *key in dictionary) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", key, dictionary[key]]];
    }
    return [parts componentsJoinedByString:@"&"];
}

- (NSDictionary<NSString *, NSString *> *)urlQueryParamsDictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *str = [self urlQueryParamsString] ?: self;
    NSArray *keyValues = [str componentsSeparatedByString:@"&"];
    if (keyValues.count == 0) {
        return nil; // empty
    }
    for (NSString *keyValueString in keyValues) {
        NSArray<NSString *> *keyValueSplit = [keyValueString componentsSeparatedByString:@"="];
        if ((keyValueSplit.count != 2) ||
            (keyValueSplit[0].length == 0) ||
            (keyValueSplit[1].length == 0)) {
            return nil; // malformed
        }
        result[keyValueSplit[0]] = keyValueSplit[1];
    }
    return result;
}

#pragma mark - Private

- (NSString *)urlQueryParamsString {
    NSURL *url = [[NSURL alloc] initWithString:self];
    if (url == nil) {
        return nil;
    }
    NSArray<NSString *> *split = [self componentsSeparatedByString:@"?"];
    if (split.count != 2) {
        return nil;
    }
    return split[1];
}

@end
