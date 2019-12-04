//
//  DFPRequestClasses.h
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 7/18/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef DFPRequestClasses_h
#define DFPRequestClasses_h

#import <Foundation/Foundation.h>

@interface GADRequest : NSObject
@property (readwrite, copy, nonatomic, nullable) NSDictionary *customTargeting;
@end

@interface DFPRequest : GADRequest
@end

@interface GADORequest : NSObject
@property (readwrite, copy, nonatomic, nullable) NSDictionary *customTargeting;
@end

@interface DFPORequest : GADORequest
@end

@interface GADNRequest : NSObject
@property (readwrite, copy, nonatomic, nullable) NSDictionary *customTargeting;
@end

@interface DFPNRequest : GADNRequest
@end





#endif /* DFPRequestClasses_h */
