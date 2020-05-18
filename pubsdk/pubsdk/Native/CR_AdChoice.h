//
//  CR_AdChoiceButton.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface CR_AdChoice : UIButton

@property (strong, nonatomic, nullable) CRNativeAd *nativeAd;

@end

NS_ASSUME_NONNULL_END
