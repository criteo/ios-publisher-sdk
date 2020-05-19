//
//  NSString+Testing.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Testing)

- (NSUInteger)ocurrencesCountOfSubstring:(NSString *)substring;

- (NSDictionary *)testing_moPubKeywordDictionary;

@end

NS_ASSUME_NONNULL_END
