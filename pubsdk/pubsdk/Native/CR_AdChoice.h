//
//  CR_AdChoiceButton.h
//  AdViewer
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CR_NativePrivacy;

NS_ASSUME_NONNULL_BEGIN

@interface CR_AdChoice : UIButton

@property (strong, nonatomic, nullable) CR_NativePrivacy *nativePrivacy;


@end

NS_ASSUME_NONNULL_END
