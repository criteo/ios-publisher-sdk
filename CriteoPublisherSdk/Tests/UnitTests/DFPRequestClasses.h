//
//  DFPRequestClasses.h
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

#ifndef DFPRequestClasses_h
#define DFPRequestClasses_h

#import <Foundation/Foundation.h>

// NOTE: This is OK that there is no explicit implementation for these interfaces.
// NOTE: The implementation is provided by GoogleMobileAds SDK.

@interface GADRequest : NSObject
@property(readwrite, copy, nonatomic, nullable) NSDictionary *customTargeting;
@end

@interface DFPRequest : GADRequest
@end

#endif /* DFPRequestClasses_h */
