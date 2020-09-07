//
//  CR_SPTIabTCFModelV1.m
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 04/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import "CR_SPTIabTCFModel.h"

@implementation CR_SPTIabTCFModel



- (BOOL)isVendorConsentGivenFor:(int)vendorId {
    return [self booleanInBitString:self.parsedVendorsConsents forId:vendorId];
}

- (BOOL)isVendorLegitInterestGivenFor:(int)vendorId {
    return [self booleanInBitString:self.parsedVendorsLegitmateInterest forId:vendorId];
}

- (BOOL)isPurposeConsentGivenFor:(int)purposeId {
    return [self booleanInBitString:self.parsedPurposesConsents forId:purposeId];
}

- (BOOL)isPurposeLegitInterestGivenFor:(int)purposeId {
    return [self booleanInBitString:self.parsedPurposesLegitmateInterest forId:purposeId];
}

- (BOOL)isSpecialFeatureOptedInFor:(int)specialFeatureId {
     return [self booleanInBitString:self.specialFeatureOptIns forId:specialFeatureId];
}

- (BOOL)isVendorDiscloseFor:(int)vendorId {
    return [self booleanInBitString:self.parsedDisclosedVendors forId:vendorId];
}

- (BOOL)isVendorAllowedFor:(int)vendorId {
    return [self booleanInBitString:self.parsedAllowedVendors forId:vendorId];
}

- (BOOL)isPublisherPurposeConsentGivenFor:(int)purposeId {
    return [self booleanInBitString:self.publisherTCParsedPurposesConsents forId:purposeId];
}

- (BOOL)isPublisherPurposeLegitInterestGivenFor:(int)purposeId {
    return [self booleanInBitString:self.publisherTCParsedPurposesLegitmateInterest forId:purposeId];
}

- (BOOL)isPublisherCustomPurposeConsentGivenFor:(int)purposeId {
    return [self booleanInBitString:self.publisherTCParsedCustomPurposesConsents forId:purposeId];
}

- (BOOL)isPublisherCustomPurposeLegitInterestGivenFor:(int)purposeId {
    return [self booleanInBitString:self.publisherTCParsedCustomPurposesLegitmateInterest forId:purposeId];
}

- (PublisherRestrictionType)publisherRestrictionTypeForVendor:(int)vendorId forPurpose:(int)purposeId {
    
    NSString *parsedVendorsPubRest = @"";
    for (CR_SPTIabPublisherRestriction *pubRest in self.publisherRestrictions) {
        if (pubRest.purposeId == purposeId) {
            parsedVendorsPubRest =  pubRest.parsedVendors;
        }
    }
    if (!parsedVendorsPubRest || parsedVendorsPubRest.length == 0 || parsedVendorsPubRest.length < vendorId) {
        return Restriction_Undefined;
    }
    NSInteger restIntvalue = [[parsedVendorsPubRest substringWithRange:NSMakeRange(vendorId-1, 1)] integerValue];
    
    return restIntvalue;
}

- (BOOL)booleanInBitString:(NSString *)bitSstring forId:(int)index {
    if (!bitSstring || bitSstring.length == 0 || bitSstring.length < index) {
        return NO;
    }
    
    return [[bitSstring substringWithRange:NSMakeRange(index-1, 1)] boolValue];
}

- (NSDictionary *)asJson {
    
    NSMutableDictionary * result = [NSMutableDictionary new];

    [result setValue:@(self.version) forKey:@"version"];
    [result setValue:self.created forKey:@"created"];
    [result setValue:self.lastUpdated forKey:@"lastUpdated"];
    [result setValue:@(self.cmpId) forKey:@"cmpId"];
    [result setValue:@(self.cmpVersion) forKey:@"cmpVersion"];
    [result setValue:@(self.consentScreen) forKey:@"consentScreen"];
    [result setValue:self.consentCountryCode forKey:@"consentCountryCode"];
    [result setValue:@(self.vendorListVersion) forKey:@"vendorListVersion"];
    [result setValue:self.parsedPurposesConsents forKey:@"parsedPurposesConsents"];
    [result setValue:self.parsedVendorsConsents forKey:@"parsedVendorsConsents"];
    
    [result setValue:self.parsedPurposesLegitmateInterest forKey:@"parsedPurposesLegitmateInterest"];
    [result setValue:self.parsedVendorsLegitmateInterest forKey:@"parsedVendorsLegitmateInterest"];
    [result setValue:@(self.policyVersion) forKey:@"policyVersion"];
    [result setValue:@(self.isServiceSpecific) forKey:@"isServiceSpecific"];
    [result setValue:@(self.useNonStandardStack) forKey:@"useNonStandardStack"];
    [result setValue:self.specialFeatureOptIns forKey:@"specialFeatureOptIns"];
    [result setValue:@(self.purposeOneTreatment) forKey:@"purposeOneTreatment"];
    [result setValue:self.publisherCountryCode forKey:@"publisherCountryCode"];
    
    [result setValue:self.parsedDisclosedVendors forKey:@"parsedDisclosedVendors"];
    [result setValue:self.parsedAllowedVendors forKey:@"parsedAllowedVendors"];
    
    [result setValue:self.publisherTCParsedPurposesConsents forKey:@"publisherTCParsedPurposesConsents"];
    [result setValue:self.publisherTCParsedPurposesLegitmateInterest forKey:@"publisherTCParsedPurposesLegitmateInterest"];
    [result setValue:self.publisherTCParsedCustomPurposesConsents forKey:@"publisherTCParsedCustomPurposesConsents"];
    [result setValue:self.publisherTCParsedCustomPurposesLegitmateInterest forKey:@"publisherTCParsedCustomPurposesLegitmateInterest"];
    
    
    NSMutableArray * pubRestArray = [[NSMutableArray alloc] initWithCapacity:self.publisherRestrictions.count];
    for (CR_SPTIabPublisherRestriction *rest in self.publisherRestrictions) {
        [pubRestArray addObject:[rest asJson]];
    }
    
    [result setValue:pubRestArray forKey:@"publisherRestrictions"];

    return result;
    
}

@end
