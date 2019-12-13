//
//  NSString+CR_UrlEncoder.h
//  pubsdk
//
//  Created by Paul Davis on 1/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CR_UrlEncoder)

- (NSString*) urlEncode;
+ (NSString *)dfpCompatibleString:(NSString*)string;
+ (NSString *)decodeDfpCompatibleString:(NSString *)string;
+ (NSString *)mopubCompatibleDisplayUrlForDisplayUrl:(NSString *)displayUrl;

@end

NS_ASSUME_NONNULL_END
