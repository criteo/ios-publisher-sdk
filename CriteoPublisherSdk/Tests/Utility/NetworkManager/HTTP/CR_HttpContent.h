//
//  CR_HttpContent.h
//  CriteoPublisherSdkTests
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum { GET, POST } CR_HTTPVerb;

NSString *NSStringFromHTTPVerb(CR_HTTPVerb verb);

/**
 Wrapper for the HTTP request and HTTP the response .
 */
@interface CR_HttpContent : NSObject

@property(nonatomic, copy, readonly) NSURL *url;
@property(nonatomic, assign, readonly) CR_HTTPVerb verb;
@property(nonatomic, copy, readonly) NSDictionary *requestBody;
@property(nonatomic, copy, readonly) NSData *responseBody;
@property(nonatomic, strong, readonly) NSError *error;
@property(nonatomic, assign, readonly) unsigned counter;

- (instancetype)initWithUrl:(NSURL *)url
                       verb:(CR_HTTPVerb)verb
                requestBody:(nullable NSDictionary *)requestBody
               responseBody:(nullable NSData *)responseBody
                      error:(nullable NSError *)error
                    counter:(unsigned)counter;

@end

NS_ASSUME_NONNULL_END
