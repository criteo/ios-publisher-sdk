//
//  CR_NetworkCache.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"
#import "CR_NetworkCaptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_NetworkSessionWriter : NSObject

+ (instancetype)defaultNetworkSessionWriter;
- (instancetype)initWithWithFileManager:(NSFileManager *)fileManager
                          fileDirectory:(NSString *)fileDirectory NS_DESIGNATED_INITIALIZER;
-(instancetype)init NS_UNAVAILABLE;

- (void)setSession:(NSArray<CR_HttpContent *> *)content forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
