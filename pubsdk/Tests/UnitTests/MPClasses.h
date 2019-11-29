//
//  MPClasses.h
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 7/26/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef MPClasses_h
#define MPClasses_h
#import <UIKit/UIKit.h>

@interface MPAdView : UIView
@property (readwrite, copy, nonatomic, nullable) NSString *keywords;
@end

@interface MPInterstitialAdController : NSObject
@property (readwrite, copy, nonatomic, nullable) NSString *keywords;
- (void) loadAd;
@end

#endif /* MPClasses_h */
