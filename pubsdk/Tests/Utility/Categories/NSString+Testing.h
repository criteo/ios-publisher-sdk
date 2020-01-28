//
//  NSString+Testing.h
//  pubsdk
//
//  Created by Romain Lofaso on 1/28/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Testing)

- (NSUInteger)ocurrencesCountOfSubstring:(NSString *)substring;

@end

NS_ASSUME_NONNULL_END
