//
//  CR_NetworkSessionReader.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_HttpContent;

NS_ASSUME_NONNULL_BEGIN

@interface CR_NetworkSessionReader : NSObject

- (NSArray<CR_HttpContent *> *)sessionForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
