//
// Created by Aleksandr Pakhmutov on 26/11/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteo.h"

@class CR_NetworkCaptor;

FOUNDATION_EXPORT NSString *const CriteoTestingPublisherId;

@interface Criteo (Testing)

@property(nonatomic, readonly) CR_NetworkCaptor *testing_networkCaptor;

+ (Criteo *)testing_criteoWithNetworkCaptor;

- (void)testing_register;

@end