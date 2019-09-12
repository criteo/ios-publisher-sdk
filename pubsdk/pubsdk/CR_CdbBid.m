//
//  CR_CdbBid.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/17/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CR_CdbBid.h"
#import "Logging.h"
#import "NSString+CR_UrlEncoder.h"

@interface CR_CdbBid ()

- (NSString*) dfpCompatibleString:(NSString*)displayUrl;
- (NSString*) mopubCompatibleDisplayUrlForDisplayUrl:(NSString*)displayUrl;

@end

@implementation CR_CdbBid

static CR_CdbBid *emptyBid;

+ (void) initialize
{
    if (self == [CR_CdbBid class])
    {
        emptyBid = [[CR_CdbBid alloc] initWithZoneId:@(0)
                                         placementId:nil
                                                 cpm:nil
                                            currency:nil
                                               width:@(0)
                                              height:@(0)
                                                 ttl:0
                                            creative:nil
                                          displayUrl:nil
                                          insertTime:nil];
    }
}

+ (instancetype) emptyBid
{
    return emptyBid;
}

- (instancetype) init {
    return [self initWithZoneId:@(497747)
                    placementId:@"adunitid"
                            cpm:@"0.00"
                       currency:@"EUR"
                          width:@(300)
                         height:@(250)
                            ttl:6000
                       creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                     displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js"
                     insertTime:[NSDate date]];
}

- (instancetype) initWithZoneId:(NSNumber *) zoneId
                    placementId:(NSString *) placementId
                            cpm:(NSString *) cpm
                       currency:(NSString *) currency
                          width:(NSNumber *) width
                         height:(NSNumber *) height
                            ttl:(NSTimeInterval) ttl
                       creative:(NSString *) creative
                     displayUrl:(NSString *) displayUrl
                     insertTime:(NSDate *) insertTime{
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
        _dfpCompatibleDisplayUrl = [self dfpCompatibleString:displayUrl];
        _mopubCompatibleDisplayUrl = [self mopubCompatibleDisplayUrlForDisplayUrl:displayUrl];
        _insertTime = insertTime;
    }
    return self;
}

- (NSString *)dfpCompatibleString:(NSString *)string
{
    NSString *dfpCompatibleString = nil;

    if(string) {
        NSData *encodedStringData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [encodedStringData base64EncodedStringWithOptions:0];
        dfpCompatibleString = [[base64String urlEncode] urlEncode];
    }

    return dfpCompatibleString;
}

- (NSString*) mopubCompatibleDisplayUrlForDisplayUrl:(NSString*)displayUrl
{
    return displayUrl;
}

// TODO : If there is a cleaner way to write this please show me
- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[CR_CdbBid class]]) {
        return NO;
    }
    CR_CdbBid *obj = (CR_CdbBid *)object;
    if((self.zoneId == obj.zoneId) || [self.zoneId isEqual:obj.zoneId]) {
        if((self.placementId == obj.placementId) || [self.placementId isEqualToString:obj.placementId]) {
            if((self.cpm == obj.cpm) || [self.cpm isEqualToString:obj.cpm]) {
                if((self.currency == obj.currency) || [self.currency isEqualToString:obj.currency]) {
                    if((self.width == obj.width) || [self.width isEqual:obj.width]) {
                        if((self.height == obj.height) || [self.height isEqual:obj.height]) {
                            if((self.creative == obj.creative) || [self.creative isEqualToString:obj.creative]) {
                                if((self.displayUrl == obj.displayUrl) || [self.displayUrl isEqualToString:obj.displayUrl]) {
                                    if(self.ttl == obj.ttl) {
                                        if((self.insertTime == obj.insertTime) || [self.insertTime isEqualToDate:obj.insertTime]) {
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
    }
    return NO;
}

+ (NSArray *) getCdbResponsesForData:(NSData *) data
                          receivedAt:(NSDate *)receivedAt
{
    NSMutableArray *responses = nil;
    NSError *e = nil;
    NSDictionary *slots = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    double defaultValue = 900;
    if (!slots) {
        CLog(@"Error parsing JSON to CdbResponse: %@" , e);
    } else {
        responses = [[NSMutableArray alloc] init];
        for (NSDictionary *slot in slots[@"slots"]) {
            NSNumber *zoneId = slot[@"zoneId"];
            NSString *placementId = slot[@"placementId"];
            // TODO: once CDB starts returning strings instead of floats, clean this up
            NSString *cpm = [slot[@"cpm"] isKindOfClass:[NSString class]]? slot[@"cpm"] : [slot[@"cpm"] stringValue];
            NSString *currency = slot[@"currency"];
            NSNumber *width = slot[@"width"];
            NSNumber *height = slot[@"height"];
            NSString *creative = slot[@"creative"];
            // Hard coding to 15 minutes for now
            // TODO: move this default to the config
            NSTimeInterval ttl = slot[@"ttl"] ? [slot[@"ttl"] doubleValue]: defaultValue;
            if ([cpm doubleValue] > 0 && ttl == 0){
                ttl = defaultValue;
            }
            NSString *displayUrl = slot[@"displayUrl"];
            CR_CdbBid *response = [[CR_CdbBid alloc] initWithZoneId:zoneId placementId:placementId cpm:cpm currency:currency width:width height:height ttl:ttl creative:creative displayUrl:displayUrl insertTime:receivedAt];
            [responses addObject:response];
        }
    }
    return responses;
}

- (instancetype) copyWithZone:(NSZone *) zone {
    CR_CdbBid *copy = [[CR_CdbBid alloc] initWithZoneId:self.zoneId
                                            placementId:self.placementId
                                                    cpm:self.cpm
                                               currency:self.currency
                                                  width:self.width
                                                 height:self.height
                                                    ttl:self.ttl
                                               creative:self.creative
                                             displayUrl:self.displayUrl
                                             insertTime:self.insertTime];
    return copy;
}

- (BOOL) isEmpty {
    CR_CdbBid *__emptyBid = [CR_CdbBid emptyBid];
    return [self isEqual:__emptyBid];
}

- (BOOL) isExpired {
    if (self.ttl <= 0) {
        return true;
    }

    return [[NSDate date]timeIntervalSinceReferenceDate] - [[self insertTime]timeIntervalSinceReferenceDate] > self.ttl;
}
@end
