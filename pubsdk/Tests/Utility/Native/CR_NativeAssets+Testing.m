//
//  CR_TestNativeAssets.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NativeAssets+Testing.h"


@implementation CR_NativeAssets (Testing)

+ (CR_NativeAssets *)nativeAssetsFromCdb {
    return [CR_NativeAssets loadNativeAssets:@"NativeAssetsFromCdb"];
}

#pragma - Private

+ (CR_NativeAssets *)loadNativeAssets:(NSString *)fileName {
    NSError *e = nil;
    NSURL *jsonURL = [[NSBundle bundleForClass:[self class]] URLForResource:fileName withExtension:@"json"];
    NSString *jsonText = [NSString stringWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&e];
    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    return [[CR_NativeAssets alloc] initWithDict:dictionary];
}

@end