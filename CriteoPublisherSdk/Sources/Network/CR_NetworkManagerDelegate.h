//
//  CR_NetworkManagerDelegate.h
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

#ifndef CR_NetworkManagerDelegate_h
#define CR_NetworkManagerDelegate_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CR_NetworkManager;

@protocol CR_NetworkManagerDelegate <NSObject>

- (void)networkManager:(CR_NetworkManager*)manager sentRequest:(NSURLRequest*)request;
- (void)networkManager:(CR_NetworkManager*)manager
      receivedResponse:(NSURLResponse*)response
              withData:(NSData*)data
                 error:(NSError*)error;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_NetworkManagerDelegate_h */
