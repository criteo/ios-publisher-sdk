//
//  CR_SPTIabTCFUtils.m
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 04/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import "CR_SPTIabTCFUtils.h"

@implementation CR_SPTIabTCFUtils

+ (unsigned char *)NSDataToBinary:(NSData *)decodedData {
  const char *byte = [decodedData bytes];
  NSUInteger length = [decodedData length];
  unsigned long bufferLength = decodedData.length * 8 - 1;
  unsigned char *buffer = (unsigned char *)calloc(bufferLength, sizeof(unsigned char));
  int prevIndex = 0;

  for (int byteIndex = 0; byteIndex < length; byteIndex++) {
    char currentByte = byte[byteIndex];
    int bufferIndex = 8 * (byteIndex + 1);

    while (bufferIndex > prevIndex) {
      if (currentByte & 0x01) {
        buffer[--bufferIndex] = '1';
      } else {
        buffer[--bufferIndex] = '0';
      }
      currentByte >>= 1;
    }

    prevIndex = 8 * (byteIndex + 1);
  }

  return buffer;
}

+ (BOOL)BinaryToBoolean:(unsigned char *)buffer atIndex:(int)index {
  return buffer[index] != '0';
}

+ (NSInteger)BinaryToDecimal:(unsigned char *)buffer
                   fromIndex:(int)startIndex
                      length:(int)totalOffset {
  size_t length = (int)strlen((const char *)buffer);

  if (length <= startIndex || length <= startIndex + totalOffset - 1) {
    return 0;
  }

  NSInteger bit = 1;
  NSInteger total = 0;

  for (int i = startIndex + totalOffset - 1; i >= startIndex; i--) {
    if (buffer[i] == '1') {
      total += bit;
    }

    bit *= 2;
  }

  return total;
}

+ (NSString *)addPaddingIfNeeded:(NSString *)base64String {
  int padLenght = (4 - (base64String.length % 4)) % 4;
  NSString *paddedBase64 =
      [NSString stringWithFormat:@"%s%.*s", [base64String UTF8String], padLenght, "=="];
  return paddedBase64;
}

+ (NSString *)replaceSafeCharacters:(NSString *)consentString {
  NSString *stringreplace = [consentString stringByReplacingOccurrencesOfString:@"-"
                                                                     withString:@"+"];
  NSString *finalString = [stringreplace stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
  return finalString;
}

+ (NSString *)safeBase64ConsentString:(NSString *)consentString {
  NSString *safeString = [CR_SPTIabTCFUtils replaceSafeCharacters:consentString];
  NSString *base64String = [CR_SPTIabTCFUtils addPaddingIfNeeded:safeString];
  return base64String;
}

@end
