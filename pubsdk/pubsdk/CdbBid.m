//
//  CdbResponse.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/17/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CdbBid.h"

@implementation CdbBid

static CdbBid *emptyBid;

+ (void) initialize
{
    if (self == [CdbBid class])
    {
        emptyBid = [[CdbBid alloc] initWithZoneId:@(0)
                                      placementId:nil
                                              cpm:@(0)
                                         currency:nil
                                            width:@(0)
                                           height:@(0)
                                              ttl:@(0)
                                         creative:nil
                                       displayUrl:nil];
    }
}

+ (instancetype) emptyBid
{
    return emptyBid;
}

- (instancetype) init {
    return [self initWithZoneId:@(497747)
                    placementId:@"adunitid"
                            cpm:@(1.1200000047683716)
                       currency:@"EUR"
                          width:@(300)
                         height:@(250)
                            ttl:@(6000)
                       creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                     displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js"];
}

- (instancetype) initWithZoneId:(NSNumber *) zoneId
                    placementId:(NSString *) placementId
                            cpm:(NSNumber *) cpm
                       currency:(NSString *) currency
                          width:(NSNumber *) width
                         height:(NSNumber *) height
                            ttl:(NSNumber *) ttl
                       creative:(NSString *) creative
                     displayUrl:(NSString *) displayUrl{
    if(self = [super init]) {
        _zoneId = zoneId;
        _placementId = placementId;
        _cpm = cpm;
        _currency = currency;
        _width = width;
        _height = height;
        _creative = creative;
        _ttl = ttl;
        _displayUrl = displayUrl;
    }
    return self;
}

// TODO : If there is a cleaner way to write this please show me
- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[CdbBid class]]) {
        return NO;
    }
    CdbBid *obj = (CdbBid *)object;
    if((self.zoneId == obj.zoneId) || [self.zoneId isEqual:obj.zoneId]) {
        if((self.placementId == obj.placementId) || [self.placementId isEqualToString:obj.placementId]) {
            if((self.cpm == obj.cpm) || [self.cpm isEqual:obj.cpm]) {
                if((self.currency == obj.currency) || [self.currency isEqualToString:obj.currency]) {
                    if((self.width == obj.width) || [self.width isEqual:obj.width]) {
                        if((self.height == obj.height) || [self.height isEqual:obj.height]) {
                            if((self.creative == obj.creative) || [self.creative isEqualToString:obj.creative]) {
                                if((self.displayUrl == obj.displayUrl) || [self.displayUrl isEqualToString:obj.displayUrl]){
                                    if((self.ttl == obj.ttl) || [self.ttl isEqual:obj.ttl]) {
                                        return YES;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
}

+ (NSArray *) getCdbResponsesFromData: (NSData *) data {
    NSMutableArray *responses = nil;
    NSError *e = nil;
    NSDictionary *slots = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    if (!slots) {
        NSLog(@"Error parsing JSON to CdbResponse: %@" , e);
    } else {
        responses = [[NSMutableArray alloc] init];
        for (NSDictionary *slot in slots[@"slots"]) {
            NSNumber *zoneId = slot[@"zoneId"];
            NSString *placementId = slot[@"placementId"];
            NSNumber *cpm = slot[@"cpm"];
            NSString *currency = slot[@"currency"];
            NSNumber *width = slot[@"width"];
            NSNumber *height = slot[@"height"];
            NSString *creative = slot[@"creative"];
            NSNumber *ttl = slot[@"ttl"];
            NSString *displayUrl = slot[@"displayUrl"];
            CdbBid *response = [[CdbBid alloc] initWithZoneId:zoneId placementId:placementId cpm:cpm currency:currency width:width height:height ttl:ttl creative:creative displayUrl:displayUrl];
            [responses addObject:response];
        }
    }
    return responses;
}

- (instancetype) copyWithZone:(NSZone *) zone {
    CdbBid *copy = [[CdbBid alloc] initWithZoneId:self.zoneId
                                      placementId:self.placementId
                                              cpm:self.cpm
                                         currency:self.currency
                                            width:self.width
                                           height:self.height
                                              ttl:self.ttl
                                         creative:self.creative
                                       displayUrl:self.displayUrl];
    return copy;
}

- (BOOL) isEmpty {
    CdbBid *__emptyBid = [CdbBid emptyBid];
    return [self isEqual:__emptyBid];
}
@end
