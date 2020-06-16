//
//  CR_URLOpenning.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CR_URLOpeningCompletion)(BOOL success);

@protocol CR_URLOpening <NSObject>

- (void)openExternalURL:(NSURL *)url;
- (void)openExternalURL:(NSURL *)url
         withCompletion:(nullable CR_URLOpeningCompletion)completion;
- (void)openExternalURL:(NSURL *)url
            withOptions:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
             completion:(nullable CR_URLOpeningCompletion)completion;

@end

@interface CR_URLOpener : NSObject <CR_URLOpening>

@end

NS_ASSUME_NONNULL_END
