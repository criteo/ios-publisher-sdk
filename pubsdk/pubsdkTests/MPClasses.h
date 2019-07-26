//
//  MPClasses.h
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 7/18/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef MPClasses_h
#define MPClasses_h

@interface MPAdView : UIView
@property (readwrite, copy, nonatomic, nullable) NSString *keywords;
@end
@implementation MPAdView
@end

@interface MPInterstitialAdController : NSObject
@property (readwrite, copy, nonatomic, nullable) NSString *keywords;
@end
@implementation MPInterstitialAdController
@end

#endif /* MPClasses_h */
