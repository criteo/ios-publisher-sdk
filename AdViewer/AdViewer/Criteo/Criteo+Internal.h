//
//  Criteo+Internal.h
//  AdViewer
//
//  Created by Paul Davis on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef Criteo_Internal_h
#define Criteo_Internal_h

#import "NetworkManagerDelegate.h"

@interface Criteo ()

@property (nonatomic) id<NetworkManagerDelegate> networkMangerDelegate;

+ (instancetype)criteo;

@end

#endif /* Criteo_Internal_h */
