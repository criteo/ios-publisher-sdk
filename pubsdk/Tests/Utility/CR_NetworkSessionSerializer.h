//
//  CR_NetworkSessionSerializer.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_HttpContent;

NS_ASSUME_NONNULL_BEGIN

@interface CR_NetworkSessionSerializer : NSObject

- (NSString *)jsonWithSession:(NSArray<CR_HttpContent *> *)session;
- (NSArray<CR_HttpContent *> *)sessionWithJson:(NSString *)json;

@end

NS_ASSUME_NONNULL_END
