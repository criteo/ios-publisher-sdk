//
//  CR_URLOpenning.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CR_URLOpeningCompletion)(BOOL success);

@protocol CR_URLOpening <NSObject>

- (void)openExternalURL:(NSURL *)url;
- (void)openExternalURL:(NSURL *)url withCompletion:(nullable CR_URLOpeningCompletion)completion;
- (void)openExternalURL:(NSURL *)url
            withOptions:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
             completion:(nullable CR_URLOpeningCompletion)completion;

@end

@interface CR_URLOpener : NSObject <CR_URLOpening>

@end

NS_ASSUME_NONNULL_END
