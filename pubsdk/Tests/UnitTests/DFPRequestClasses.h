//
//  DFPRequestClasses.h
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef DFPRequestClasses_h
#define DFPRequestClasses_h

#import <Foundation/Foundation.h>

//NOTE: This is OK that there is no explicit implementation for these interfaces.
//NOTE: The implementation is provided by GoogleMobileAds SDK.

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
