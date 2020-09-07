//
//  CR_SPTIabPublisherRestriction.m
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 05/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import "CR_SPTIabPublisherRestriction.h"

@implementation CR_SPTIabPublisherRestriction

- (NSDictionary *)asJson {
  NSMutableDictionary *result = [NSMutableDictionary new];

  [result setValue:@(self.purposeId) forKey:@"purposeId"];
  [result setValue:@(self.retrictionType) forKey:@"retrictionType"];
  [result setValue:self.parsedVendors forKey:@"parsedVendors"];

  return result;
}

- (NSString *)parsedVendors {
  NSMutableString *retString = [NSMutableString new];

  NSInteger maxId = [[self.vendorsIds valueForKeyPath:@"@max.self"] integerValue];
  NSString *typeString = [NSString stringWithFormat:@"%ld", (long)self.retrictionType];
  NSString *restrictionUndefinedString =
      [NSString stringWithFormat:@"%ld", (long)Restriction_Undefined];
  for (int i = 1; i <= (int)maxId; i++) {
    if ([self.vendorsIds containsObject:[NSNumber numberWithInteger:i]]) {
      [retString appendString:typeString];
    } else {
      [retString appendString:restrictionUndefinedString];
    }
  }
  return retString;
}

@end
