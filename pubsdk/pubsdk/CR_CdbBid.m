//
//  CR_CdbBid.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_CdbBid.h"
#import "Logging.h"
#import "NSString+CR_Url.h"
#import "NSObject+Criteo.h"
#import "NSString+Criteo.h"

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
                                        nativeAssets:nil
                                        impressionId:nil];
    }
}

+ (instancetype) emptyBid
{
    return emptyBid;
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
                   nativeAssets:(CR_NativeAssets *) nativeAssets
                   impressionId:(NSString *) impressionId {
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
        _impressionId = impressionId;
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
        NSString *impId = slot[@"impId"];
        // Hard coding to 15 minutes for now
        // TODO: move this default to the config
        NSTimeInterval ttl = (slot && slot[@"ttl"]) ? [slot[@"ttl"] doubleValue]: defaultValue;
        if ([cpm doubleValue] > 0 && ttl == 0){
            ttl = defaultValue;
        }
        NSString *displayUrl = [NSString stringWithStringOrNil:slot[@"displayUrl"]];
        NSDictionary *assetsDict = slot[@"native"];
        CR_NativeAssets *nativeAssets = assetsDict ? [[CR_NativeAssets alloc] initWithDict:assetsDict] : nil;
        self = [[CR_CdbBid alloc] initWithZoneId:zoneId
                                     placementId:placementId
                                             cpm:cpm
                                        currency:currency
                                           width:width
                                          height:height
                                             ttl:ttl
                                        creative:creative
                                      displayUrl:displayUrl
                                      insertTime:receivedAt
                                    nativeAssets:nativeAssets
                                    impressionId:impId];
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
    hashval ^= _impressionId.hash;
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
    result &= [NSObject object:_impressionId isEqualTo:otherCdbBid.impressionId];
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
                                           nativeAssets:self.nativeAssets
                                           impressionId:self.impressionId];
    return copy;
}

- (BOOL) isEmpty {
    CR_CdbBid *__emptyBid = [CR_CdbBid emptyBid];
    return [self isEqual:__emptyBid];
}

- (BOOL)isExpired {
    if (self.ttl <= 0) {
        return true;
    }

    NSDate *now = [NSDate date];
    NSComparisonResult comp = [self.expirationDate compare:now];
    BOOL expired = comp == NSOrderedAscending;
    return expired;
}

- (BOOL)isInSilenceMode {
    return (self.cpm.floatValue == 0.f) && (self.ttl > 0.);
}

- (BOOL)isValid {
    return [[NSScanner scannerWithString:self.cpm] scanFloat:NULL] &&
           self.cpm.floatValue >= 0.0f                             &&
           [self isValidNativeAssetsOrUrl];
}

- (BOOL)isRenewable {
    BOOL result = !self.isInSilenceMode || self.isExpired;
    return result;
}

#pragma mark - Description

- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"<%@\n", NSStringFromClass(self.class)];
    [desc appendFormat:@"\t%@:\t%d\n", NSStringFromSelector(@selector(isRenewable)), self.isRenewable];
    [desc appendFormat:@"\t%@:\t%d\n", NSStringFromSelector(@selector(isExpired)), self.isExpired];
    [desc appendFormat:@"\t%@:\t%d\n", NSStringFromSelector(@selector(isInSilenceMode)), self.isInSilenceMode];
    [desc appendFormat:@"\t%@:\t%@\n", NSStringFromSelector(@selector(insertTime)), self.insertTime];
    [desc appendFormat:@"\t%@:\t%@\n", NSStringFromSelector(@selector(expirationDate)), self.expirationDate];
    [desc appendFormat:@"\t%@:\t%f\n", NSStringFromSelector(@selector(ttl)), self.ttl];
    [desc appendString:@">"];
    return desc;
}

#pragma mark - Private

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

- (NSDate *)expirationDate {
    NSDate *result = [self.insertTime dateByAddingTimeInterval:self.ttl];
    return result;
}

@end
