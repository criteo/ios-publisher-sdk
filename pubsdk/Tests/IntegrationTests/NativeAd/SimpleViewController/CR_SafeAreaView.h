//
//  CR_SafeAreaView.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(11.0)) @interface CR_SafeAreaView : UIView

@property (assign, nonatomic) CGRect unsafeAreaFrame;
@property (assign, nonatomic) CGRect safeAreaFrame;

@end

NS_ASSUME_NONNULL_END
