//
//  CRInterstitial+Internal.h
//  pubsdk
//
//  Created by Julien Stoeffler on 4/15/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRInterstitial_Internal_h
#define CRInterstitial_Internal_h

#import "Criteo.h"
#import "CR_InterstitialViewController.h"

@interface CRInterstitial (Internal)

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController;

@end


#endif /* CRInterstitial_Internal_h */
