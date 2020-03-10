//
// Created by Vincent Guerci on 10/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InterstitialUpdateDelegate <NSObject>
- (void)interstitialUpdated:(BOOL)loaded;
@end