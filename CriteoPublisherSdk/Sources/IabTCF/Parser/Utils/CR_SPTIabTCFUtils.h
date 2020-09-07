//
//  CR_SPTIabTCFUtils.h
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 04/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CR_SPTIabTCFUtils : NSObject

+(NSString*)addPaddingIfNeeded:(NSString*)base64String;
+(unsigned char*)NSDataToBinary:(NSData *)decodedData;
+(NSString*)replaceSafeCharacters:(NSString*)consentString;
+(NSString*)safeBase64ConsentString:(NSString*)consentString;
+(BOOL)BinaryToBoolean:(unsigned char*)buffer atIndex:(int)index;
+(NSInteger)BinaryToDecimal:(unsigned char*)buffer fromIndex:(int)startIndex length:(int)totalOffset;

@end

NS_ASSUME_NONNULL_END
