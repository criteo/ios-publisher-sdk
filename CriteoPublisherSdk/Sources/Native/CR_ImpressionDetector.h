//
//  CR_ImpressionDetector.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIView;
@protocol CR_ImpressionDetectorDelegate;

@interface CR_ImpressionDetector : NSObject

@property(weak, nonatomic, readonly) UIView *view;
@property(weak, nonatomic) id<CR_ImpressionDetectorDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

- (void)startDetection;
- (void)stopDetection;

+ (BOOL)isViewVisible:(UIView *)view;

@end

@protocol CR_ImpressionDetectorDelegate <NSObject>

- (void)impressionDetectorDidDetectImpression:(CR_ImpressionDetector *)detector;

@end

NS_ASSUME_NONNULL_END
