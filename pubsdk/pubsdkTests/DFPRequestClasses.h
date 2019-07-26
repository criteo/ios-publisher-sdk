//
//  DFPRequestClasses.h
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 7/18/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef DFPRequestClasses_h
#define DFPRequestClasses_h

@interface GADRequest : NSObject
@property (readwrite, copy, nonatomic, nullable) NSDictionary *customTargeting;
@end
@implementation GADRequest
@end

@interface DFPRequest : GADRequest
@end
@implementation DFPRequest
@end

@interface GADORequest : NSObject
@property (readwrite, copy, nonatomic, nullable) NSDictionary *customTargeting;
@end
@implementation GADORequest
@end

@interface DFPORequest : GADORequest
@end
@implementation DFPORequest
@end

@interface GADNRequest : NSObject
@property (readwrite, copy, nonatomic, nullable) NSDictionary *customTargeting;
@end
@implementation GADNRequest
@end

@interface DFPNRequest : GADNRequest
@end
@implementation DFPNRequest
@end





#endif /* DFPRequestClasses_h */
