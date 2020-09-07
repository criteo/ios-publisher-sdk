//
//  CR_SPTIabPublisherRestriction.h
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 05/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PublisherRestrictionType) {
  Restriction_NotAllowedByPublisher = 0,
  Restriction_RequireConsent = 1,
  Restriction_RequireLegitimateInterest = 2,
  Restriction_Undefined = 3
};

@interface CR_SPTIabPublisherRestriction : NSObject

@property(assign, nonatomic) NSInteger purposeId;
@property(assign, nonatomic) PublisherRestrictionType retrictionType;
@property(retain, nonatomic) NSArray *vendorsIds;
@property(retain, nonatomic) NSString *parsedVendors;

- (NSDictionary *)asJson;

@end

NS_ASSUME_NONNULL_END
