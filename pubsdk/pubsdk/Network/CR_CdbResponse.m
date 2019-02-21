//
//  CR_CdbResponse.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 2/12/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_CdbResponse.h"
#import "Logging.h"

@implementation CR_CdbResponse

- (instancetype)init {
    if(self = [super init]) {
        _cdbBids = nil;
        _timeToNextCall = 0;
    }
    return self;
}

+ (CR_CdbResponse *)getCdbResponseForData:(NSData *)data receivedAt:(NSDate *)receivedAt {
    CR_CdbResponse *cdbResponse = [[CR_CdbResponse alloc] init];
    cdbResponse.responseTime = receivedAt;
    cdbResponse.cdbBids = [CR_CdbBid getCdbResponsesForData:data receivedAt:receivedAt];
    cdbResponse.timeToNextCall = 0;

    NSError *e = nil;
    NSDictionary *timeToNextCall = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&e];
    if (e) {
        CLog(@"Error parsing JSON to timeToNextCall of CdbResponse: %@" , e);
    } else if(timeToNextCall[@"timeToNextCall"]
              && [timeToNextCall[@"timeToNextCall"] isKindOfClass:[NSNumber class]]) {
        cdbResponse.timeToNextCall = [timeToNextCall[@"timeToNextCall"] unsignedIntegerValue];
    }
    return cdbResponse;
}

@end
