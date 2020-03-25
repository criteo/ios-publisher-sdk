//
//  CR_CdbRequest.m
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 25/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_CdbRequest.h"
#import "CR_CdbResponse.h"

@interface CR_CdbRequest ()

@property (strong, nonatomic) NSDictionary *adUnitToImpressionIdMap;

@end

@implementation CR_CdbRequest

- (instancetype)initWithAdUnits:(CR_CacheAdUnitArray *)adUnits {
    if(self = [super init]) {
        _adUnits = adUnits;
        _adUnitToImpressionIdMap = [self buildAdUnitToImpressionIdMapForAdUnits:adUnits];
    }
    return self;
}

- (NSDictionary *)buildAdUnitToImpressionIdMapForAdUnits:(CR_CacheAdUnitArray *)adUnits {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for(CR_CacheAdUnit *adUnit in adUnits) {
        //todo add proper algorithm for generating impressionId
        NSString *lowercaseUuid = [[[NSUUID UUID] UUIDString] lowercaseString];
        map[adUnit] = [lowercaseUuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return map;
}

- (NSString *)impressionIdForAdUnit:(CR_CacheAdUnit *)adUnit {
    return self.adUnitToImpressionIdMap[adUnit];
}

- (NSArray<NSString *> *)impressionIds {
    return self.adUnitToImpressionIdMap.allValues;
}

- (NSArray<NSString *> *)impressionIdsMissingInCdbResponse:(CR_CdbResponse *)cdbResponse {
    NSMutableArray<NSString *> *cdbRequestBidImpresionIds = [[NSMutableArray alloc] init];
    for(CR_CdbBid *bid in cdbResponse.cdbBids) {
        if(bid.impressionId) {
            [cdbRequestBidImpresionIds addObject:bid.impressionId];
        }
    }
    NSMutableArray<NSString *> *result = [NSMutableArray arrayWithArray:self.impressionIds];
    [result removeObjectsInArray:cdbRequestBidImpresionIds];
    return result;
}

@end
