//
//  CR_CdbBid.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CR_CdbBid.h"
#import "NSObject+Criteo.h"
#import "NSString+Criteo.h"
#import "CRConstants.h"

@interface CR_CdbBid ()

@end

@implementation CR_CdbBid

static CR_CdbBid *emptyBid;

+ (void)initialize {
  if (self == [CR_CdbBid class]) {
    emptyBid = [[CR_CdbBid alloc] initWithZoneId:@(0)
                                     placementId:nil
                                             cpm:nil
                                        currency:nil
                                           width:@(0)
                                          height:@(0)
                                             ttl:0
                                        creative:nil
                                      displayUrl:nil
                                         isVideo:NO
                                      insertTime:nil
                                    nativeAssets:nil
                                    impressionId:nil
                           skAdNetworkParameters:nil];
  }
}

+ (instancetype)emptyBid {
  return emptyBid;
}

- (instancetype)initWithZoneId:(NSNumber *)zoneId
                   placementId:(NSString *)placementId
                           cpm:(NSString *)cpm
                      currency:(NSString *)currency
                         width:(NSNumber *)width
                        height:(NSNumber *)height
                           ttl:(NSTimeInterval)ttl
                      creative:(NSString *)creative
                    displayUrl:(NSString *)displayUrl
                       isVideo:(BOOL)isVideo
                    insertTime:(NSDate *)insertTime
                  nativeAssets:(CR_NativeAssets *)nativeAssets
                  impressionId:(NSString *)impressionId
         skAdNetworkParameters:(CR_SKAdNetworkParameters *)skAdNetworkParameters {
  if (self = [super init]) {
    _zoneId = zoneId;
    _placementId = placementId;
    _cpm = cpm;
    _currency = currency;
    _width = width;
    _height = height;
    _creative = creative;
    _ttl = ttl;
    _displayUrl = displayUrl;
    _isVideo = isVideo;
    _insertTime = insertTime;
    _nativeAssets = [nativeAssets copy];
    _impressionId = impressionId;
    _skAdNetworkParameters = [skAdNetworkParameters copy];
  }
  return self;
}

- (instancetype)initWithDict:(NSDictionary *)slot receivedAt:(NSDate *)receivedAt {
  self = [super init];
  if (self) {
    NSNumber *zoneId = slot[@"zoneId"];
    NSString *placementId = slot[@"placementId"];
    // TODO: once CDB starts returning strings instead of floats, clean this up
    NSString *cpm =
        [slot[@"cpm"] isKindOfClass:[NSString class]] ? slot[@"cpm"] : [slot[@"cpm"] stringValue];
    NSString *currency = slot[@"currency"];
    NSNumber *width = slot[@"width"];
    NSNumber *height = slot[@"height"];
    NSString *creative = slot[@"creative"];
    NSString *impId = slot[@"impId"];
    NSTimeInterval ttl =
        (slot && slot[@"ttl"]) ? [slot[@"ttl"] doubleValue] : CRITEO_DEFAULT_BID_TTL_IN_SECONDS;
    NSString *displayUrl = [NSString cr_StringWithStringOrNil:slot[@"displayUrl"]];
    BOOL isVideo = [slot[@"isVideo"] boolValue];
    NSDictionary *assetsDict = slot[@"native"];
    CR_NativeAssets *nativeAssets =
        assetsDict ? [[CR_NativeAssets alloc] initWithDict:assetsDict] : nil;
    NSDictionary *skAdNetworkDict = slot[@"skAdNetwork"];
    CR_SKAdNetworkParameters *skAdNetworkParameters =
        skAdNetworkDict ? [[CR_SKAdNetworkParameters alloc] initWithDict:skAdNetworkDict] : nil;
    self = [[CR_CdbBid alloc] initWithZoneId:zoneId
                                 placementId:placementId
                                         cpm:cpm
                                    currency:currency
                                       width:width
                                      height:height
                                         ttl:ttl
                                    creative:creative
                                  displayUrl:displayUrl
                                     isVideo:isVideo
                                  insertTime:receivedAt
                                nativeAssets:nativeAssets
                                impressionId:impId
                       skAdNetworkParameters:skAdNetworkParameters];
  }
  return self;
}

- (NSUInteger)hash {
  NSUInteger hash = _placementId.hash;
  hash = hash * 31u + _zoneId.hash;
  hash = hash * 31u + _cpm.hash;
  hash = hash * 31u + _currency.hash;
  hash = hash * 31u + _width.hash;
  hash = hash * 31u + _height.hash;
  hash = hash * 31u + @(_ttl).hash;
  hash = hash * 31u + _creative.hash;
  hash = hash * 31u + _displayUrl.hash;
  hash = hash * 31u + _impressionId.hash;
  hash = hash * 31u + _isVideo;
  hash = hash * 31u + _insertTime.hash;
  hash = hash * 31u + _nativeAssets.hash;
  return hash;
}

- (BOOL)isEqual:(nullable id)other {
  if (!other || ![other isMemberOfClass:CR_CdbBid.class]) {
    return NO;
  }
  CR_CdbBid *otherCdbBid = (CR_CdbBid *)other;
  BOOL result = YES;
  result &= [NSObject cr_object:_zoneId isEqualTo:otherCdbBid.zoneId];
  result &= [NSObject cr_object:_placementId isEqualTo:otherCdbBid.placementId];
  result &= [NSObject cr_object:_cpm isEqualTo:otherCdbBid.cpm];
  result &= [NSObject cr_object:_currency isEqualTo:otherCdbBid.currency];
  result &= [NSObject cr_object:_width isEqualTo:otherCdbBid.width];
  result &= [NSObject cr_object:_height isEqualTo:otherCdbBid.height];
  result &= [NSObject cr_object:_creative isEqualTo:otherCdbBid.creative];
  result &= [NSObject cr_object:_displayUrl isEqualTo:otherCdbBid.displayUrl];
  result &= _isVideo == otherCdbBid.isVideo;
  result &= _ttl == otherCdbBid.ttl;
  result &= [NSObject cr_object:_insertTime isEqualTo:otherCdbBid.insertTime];
  result &= [NSObject cr_object:_nativeAssets isEqualTo:otherCdbBid.nativeAssets];
  result &= [NSObject cr_object:_impressionId isEqualTo:otherCdbBid.impressionId];
  return result;
}

+ (NSArray<CR_CdbBid *> *)cdbBidsWithSlots:(NSArray *)slots receivedAt:(NSDate *)receivedAt {
  NSMutableArray<CR_CdbBid *> *bids = [[NSMutableArray alloc] init];
  for (NSDictionary *slot in slots) {
    [bids addObject:[[CR_CdbBid alloc] initWithDict:slot receivedAt:receivedAt]];
  }
  return bids;
}

- (instancetype)copyWithZone:(NSZone *)zone {
  CR_CdbBid *copy = [[CR_CdbBid alloc] initWithZoneId:self.zoneId
                                          placementId:self.placementId
                                                  cpm:self.cpm
                                             currency:self.currency
                                                width:self.width
                                               height:self.height
                                                  ttl:self.ttl
                                             creative:self.creative
                                           displayUrl:self.displayUrl
                                              isVideo:self.isVideo
                                           insertTime:self.insertTime
                                         nativeAssets:self.nativeAssets
                                         impressionId:self.impressionId
                                skAdNetworkParameters:nil];
  return copy;
}

- (BOOL)isEmpty {
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
  return self.isValidCpm && self.isValidNativeAssetsOrUrl;
}

- (BOOL)isRenewable {
  return !self.isInSilenceMode || self.isExpired;
}

- (BOOL)isImmediate {
  return self.cpm.floatValue > 0 && self.ttl == 0;
}

- (void)setDefaultTtl {
  _ttl = CRITEO_DEFAULT_BID_TTL_IN_SECONDS;
}

#pragma mark - Description

- (NSString *)description {
  NSMutableString *desc = [[NSMutableString alloc] init];
  [desc appendFormat:@"<%@\n", NSStringFromClass(self.class)];
  [desc
      appendFormat:@"\t%@:\t%d\n", NSStringFromSelector(@selector(isRenewable)), self.isRenewable];
  [desc appendFormat:@"\t%@:\t%d\n", NSStringFromSelector(@selector(isExpired)), self.isExpired];
  [desc appendFormat:@"\t%@:\t%d\n", NSStringFromSelector(@selector(isInSilenceMode)),
                     self.isInSilenceMode];
  [desc appendFormat:@"\t%@:\t%@\n", NSStringFromSelector(@selector(insertTime)), self.insertTime];
  [desc appendFormat:@"\t%@:\t%@\n", NSStringFromSelector(@selector(expirationDate)),
                     self.expirationDate];
  [desc appendFormat:@"\t%@:\t%f\n", NSStringFromSelector(@selector(ttl)), self.ttl];
  [desc appendString:@">"];
  return desc;
}

#pragma mark - Private

- (BOOL)isValidCpm {
  return [[NSScanner scannerWithString:self.cpm] scanFloat:NULL] && self.cpm.floatValue >= 0.0f;
}

- (BOOL)isValidNativeAssetsOrUrl {
  if (self.nativeAssets) {
    return self.nativeAssets.privacy.optoutClickUrl.length > 0 &&
           self.nativeAssets.privacy.optoutImageUrl.length > 0 &&
           self.nativeAssets.products.count > 0 && self.nativeAssets.impressionPixels.count > 0;
  } else {
    return self.displayUrl.length > 0;
  }
}

- (NSDate *)expirationDate {
  NSDate *result = [self.insertTime dateByAddingTimeInterval:self.ttl];
  return result;
}

@end
