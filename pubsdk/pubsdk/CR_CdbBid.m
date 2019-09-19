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
#import "NSObject+Criteo.h"

@interface CR_CdbBid ()

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
                                          insertTime:nil
                                        nativeAssets:nil];
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
                     insertTime:[NSDate date]
                   nativeAssets:nil];
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
                     insertTime:(NSDate *) insertTime
                   nativeAssets:(CR_NativeAssets *) nativeAssets {
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
        _dfpCompatibleDisplayUrl = [NSString dfpCompatibleString:displayUrl];
        _mopubCompatibleDisplayUrl = [NSString mopubCompatibleDisplayUrlForDisplayUrl:displayUrl];
        _insertTime = insertTime;
        _nativeAssets = [nativeAssets copy];
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)slot receivedAt:(NSDate *)receivedAt {
    const double defaultValue = 900;
    self = [super init];
    if (self) {
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
        NSTimeInterval ttl = (slot && slot[@"ttl"]) ? [slot[@"ttl"] doubleValue]: defaultValue;
        if ([cpm doubleValue] > 0 && ttl == 0){
            ttl = defaultValue;
        }
        NSString *displayUrl = slot[@"displayUrl"];
        NSDictionary *assetsDict = slot[@"native"];
        CR_NativeAssets *nativeAssets = assetsDict ? [[CR_NativeAssets alloc] initWithDict:assetsDict] : nil;
        self = [[CR_CdbBid alloc] initWithZoneId:zoneId placementId:placementId cpm:cpm currency:currency width:width height:height ttl:ttl creative:creative displayUrl:displayUrl insertTime:receivedAt nativeAssets:nativeAssets];
    }
    return self;
}

// Hash values of two CR_NativeAssets objects must be the same if the objects are equal. The reverse is not
// guaranteed (nor does it need to be).
- (NSUInteger)hash {
    NSUInteger hashval = 0;
    hashval ^= _zoneId.hash;
    hashval ^= _placementId.hash;
    hashval ^= _cpm.hash;
    hashval ^= _currency.hash;
    hashval ^= _width.hash;
    hashval ^= _height.hash;
    hashval ^= _creative.hash;
    hashval ^= _displayUrl.hash;
    hashval ^= (NSUInteger)_ttl;
    hashval ^= _insertTime.hash;
    hashval ^= _nativeAssets.hash;
    return hashval;
}

- (BOOL)isEqual:(nullable id)other {
    if (!other || ![other isMemberOfClass:CR_CdbBid.class]) { return NO; }
    CR_CdbBid *otherCdbBid = (CR_CdbBid *)other;
    BOOL result = YES;
    result &= [NSObject object:_zoneId       isEqualTo:otherCdbBid.zoneId];
    result &= [NSObject object:_placementId  isEqualTo:otherCdbBid.placementId];
    result &= [NSObject object:_cpm          isEqualTo:otherCdbBid.cpm];
    result &= [NSObject object:_currency     isEqualTo:otherCdbBid.currency];
    result &= [NSObject object:_width        isEqualTo:otherCdbBid.width];
    result &= [NSObject object:_height       isEqualTo:otherCdbBid.height];
    result &= [NSObject object:_creative     isEqualTo:otherCdbBid.creative];
    result &= [NSObject object:_displayUrl   isEqualTo:otherCdbBid.displayUrl];
    result &= _ttl                                  == otherCdbBid.ttl;
    result &= [NSObject object:_insertTime   isEqualTo:otherCdbBid.insertTime];
    result &= [NSObject object:_nativeAssets isEqualTo:otherCdbBid.nativeAssets];
    return result;
}

+ (NSArray *) getCdbResponsesForData:(NSData *) data
                          receivedAt:(NSDate *)receivedAt
{
    NSMutableArray *responses = nil;
    NSError *e = nil;
    NSDictionary *slots = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    if (!slots) {
        CLog(@"Error parsing JSON to CdbResponse: %@" , e);
    } else {
        responses = [[NSMutableArray alloc] init];
        for (NSDictionary *slot in slots[@"slots"]) {
            [responses addObject:[[CR_CdbBid alloc] initWithDict:slot receivedAt:receivedAt]];
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
                                             insertTime:self.insertTime
                                           nativeAssets:self.nativeAssets];
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

- (BOOL)isValid {
    return self.cpm.floatValue > 0.0f   &&
           [self isValidNativeAssetsOrUrl];
}

- (BOOL)isValidNativeAssetsOrUrl {
    if (self.nativeAssets) {
        return self.nativeAssets.privacy.optoutClickUrl.length > 0 &&
               self.nativeAssets.privacy.optoutImageUrl.length > 0 &&
               self.nativeAssets.products.count > 0                &&
               self.nativeAssets.impressionPixels.count > 0;
    }
    else {
        return self.displayUrl.length > 0;
    }
}

@end
