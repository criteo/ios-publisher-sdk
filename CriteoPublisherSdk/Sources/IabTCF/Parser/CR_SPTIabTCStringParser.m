//
//  CR_SPTIabConsentStringParser.m
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 04/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import "CR_SPTIabTCStringParser.h"
#import "CR_SPTIabTCFUtils.h"
#import "CR_SPTIabTCFConstants.h"
#import "CR_SPTIabPublisherRestriction.h"

typedef NS_ENUM(NSInteger, CR_SPTIabTCFSegmentType) {
  SegmentTypeCore = 0,
  SegmentTypeDisclosedVendors = 1,
  SegmentTypeAllowedVendors = 2,
  SegmentTypePublisherTC = 3
};

typedef NS_ENUM(NSInteger, SPTTcfDecoderVendorStringType) {
  DecodeStringVendorsDisclosed = 0,
  DecodeStringVendorsAllowed = 1,
};

@interface SPTDecodedStringAndOffset : NSObject

@property(assign, nonatomic) int offset;
@property(retain, nonatomic) NSString *value;

@end

@implementation SPTDecodedStringAndOffset

@end

@interface SPTDecodedPublisherRestrictionAndOffset : NSObject

@property(assign, nonatomic) int offset;
@property(retain, nonatomic) NSArray<CR_SPTIabPublisherRestriction *> *value;

@end

@implementation SPTDecodedPublisherRestrictionAndOffset

@end

@interface SPTVendorIdsAndOffset : NSObject

@property(assign, nonatomic) int offset;
@property(retain, nonatomic) NSArray<NSNumber *> *value;

@end

@implementation SPTVendorIdsAndOffset

@end

@implementation CR_SPTIabTCStringParser

+ (CR_SPTIabTCFModel *)parseConsentString:(NSString *)consentString {
  CR_SPTIabTCFModel *model = [CR_SPTIabTCFModel new];

  NSArray *segmentsStrings = [consentString componentsSeparatedByString:@"."];

  if (segmentsStrings.count == 0) {
    return NULL;
  }

  NSString *core = segmentsStrings[0];
  [[self class] completeModel:model withCoreString:core];

  if (model.version == 0) {
    return NULL;
  }

  if (segmentsStrings.count < 1) {
    return model;
  }
  for (int i = 1; i < segmentsStrings.count; i++) {
    NSString *segString = segmentsStrings[i];
    [[self class] completeModel:model
                        forType:DecodeStringVendorsDisclosed
              withVendorsString:segString];
    [[self class] completeModel:model
                        forType:DecodeStringVendorsAllowed
              withVendorsString:segString];
    [[self class] completeModel:model withPublisherPurposesTransparencyConsent:segString];
  }

  return model;
}

+ (void)completeModel:(CR_SPTIabTCFModel *)model withCoreString:(NSString *)coreString {
  unsigned char *binaryCharBuffer = [[self class] binaryFromString:coreString];

  if (!binaryCharBuffer) {
    return;
  }

  NSInteger version = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                               fromIndex:VERSION_BIT_OFFSET
                                                  length:VERSION_BIT_LENGTH];
  model.version = version;
  model.created = [[self class] decodeDateFromBinary:binaryCharBuffer
                                           fromIndex:CREATED_BIT_OFFSET
                                              length:CREATED_BIT_LENGTH];
  model.lastUpdated = [[self class] decodeDateFromBinary:binaryCharBuffer
                                               fromIndex:LAST_UPDATED_BIT_OFFSET
                                                  length:CREATED_BIT_LENGTH];
  model.cmpId = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                         fromIndex:CMP_ID_BIT_OFFSET
                                            length:CMP_ID_BIT_LENGTH];
  model.cmpVersion = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                              fromIndex:CMP_VERSION_BIT_OFFSET
                                                 length:CMP_VERSION_BIT_LENGTH];
  model.consentScreen = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                 fromIndex:CONSENT_SCREEN_BIT_OFFSET
                                                    length:CONSENT_SCREEN_BIT_LENGTH];
  model.consentCountryCode =
      [[self class] decode6BitCharStringFromBinary:binaryCharBuffer
                                         fromIndex:CONSENT_LANGUAGE_BIT_OFFSET
                                            length:CONSENT_LANGUAGE_BIT_LENGTH];
  model.vendorListVersion = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                     fromIndex:VENDOR_LIST_VERSION_BIT_OFFSET
                                                        length:VENDOR_LIST_VERSION_BIT_LENGTH];

  if (version == 1) {
    model.parsedPurposesConsents =
        [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                           fromIndex:PURPOSES_ALLOWED_V1_BIT_OFFSET
                                              length:PURPOSES_ALLOWED_V1_BIT_LENGTH];
    model.parsedVendorsConsents =
        [[self class] decodeVendorBitChainStringFromBinary:binaryCharBuffer
                                                 fromIndex:MAX_VENDOR_ID_V1_BIT_OFFSET
                                                  version1:YES]
            .value;
  } else if (version == 2) {
    model.policyVersion = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                   fromIndex:POLICY_VERSION_BIT_OFFSET
                                                      length:POLICY_VERSION_BIT_LENGTH];
    model.isServiceSpecific = [CR_SPTIabTCFUtils BinaryToBoolean:binaryCharBuffer
                                                         atIndex:IS_SERVICE_SPECIFIC_BIT];
    model.useNonStandardStack = [CR_SPTIabTCFUtils BinaryToBoolean:binaryCharBuffer
                                                           atIndex:USE_NON_STANDART_STACK_BIT];
    model.specialFeatureOptIns =
        [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                           fromIndex:SPECIAL_FEATURE_OPTINS_BIT_OFFSET
                                              length:SPECIAL_FEATURE_OPTINS_BIT_LENGHT];
    model.parsedPurposesConsents =
        [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                           fromIndex:PURPOSES_CONSENT_V2_BIT_OFFSET
                                              length:PURPOSES_CONSENT_V2_BIT_LENGTH];
    model.parsedPurposesLegitmateInterest =
        [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                           fromIndex:PURPOSES_LEGIT_INTEREST_BIT_OFFSET
                                              length:PURPOSES_LEGIT_INTEREST_BIT_LENGTH];
    model.purposeOneTreatment = [CR_SPTIabTCFUtils BinaryToBoolean:binaryCharBuffer
                                                           atIndex:PURPOSE_ONE_TREATMENT_BIT];
    model.publisherCountryCode =
        [[self class] decode6BitCharStringFromBinary:binaryCharBuffer
                                           fromIndex:PUBLISHER_COUNTRY_CODE_BIT_OFFSET
                                              length:PUBLISHER_COUNTRY_CODE_BIT_LENGTH];

    // Variable lenght fields from here order matters

    SPTDecodedStringAndOffset *consentAndOffset;
    int variableOffset = MAX_VENDOR_ID_V2_BIT_OFFSET;

    consentAndOffset = [[self class] decodeVendorBitChainStringFromBinary:binaryCharBuffer
                                                                fromIndex:variableOffset
                                                                 version1:NO];
    model.parsedVendorsConsents = consentAndOffset.value;
    variableOffset = MAX_VENDOR_ID_V2_BIT_OFFSET + consentAndOffset.offset;

    consentAndOffset = [[self class] decodeVendorBitChainStringFromBinary:binaryCharBuffer
                                                                fromIndex:variableOffset
                                                                 version1:NO];
    model.parsedVendorsLegitmateInterest = consentAndOffset.value;
    variableOffset += consentAndOffset.offset;

    SPTDecodedPublisherRestrictionAndOffset *pubRestAndOffset;
    pubRestAndOffset =
        [[self class] decodePublisherRestrictionBitChainStringFromBinary:binaryCharBuffer
                                                               fromIndex:variableOffset];
    model.publisherRestrictions = pubRestAndOffset.value;
  }

  free(binaryCharBuffer);
}

+ (void)completeModel:(CR_SPTIabTCFModel *)model
              forType:(SPTTcfDecoderVendorStringType)type
    withVendorsString:(NSString *)vendors {
  unsigned char *binaryCharBuffer = [[self class] binaryFromString:vendors];

  if (!binaryCharBuffer) {
    return;
  }

  CR_SPTIabTCFSegmentType segmentType = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                                 fromIndex:0
                                                                    length:SEGMENT_TYPE_BIT_LENGTH];
  SPTDecodedStringAndOffset *consentAndOffset;
  if (type == DecodeStringVendorsDisclosed) {
    if (segmentType != SegmentTypeDisclosedVendors) {
      return;
    }
    consentAndOffset = [[self class] decodeVendorBitChainStringFromBinary:binaryCharBuffer
                                                                fromIndex:SEGMENT_TYPE_BIT_LENGTH
                                                                 version1:NO];
    model.parsedDisclosedVendors = consentAndOffset.value;
  }
  if (type == DecodeStringVendorsAllowed) {
    if (segmentType != SegmentTypeAllowedVendors) {
      return;
    }
    consentAndOffset = [[self class] decodeVendorBitChainStringFromBinary:binaryCharBuffer
                                                                fromIndex:SEGMENT_TYPE_BIT_LENGTH
                                                                 version1:NO];
    model.parsedAllowedVendors = consentAndOffset.value;
  }
  free(binaryCharBuffer);
}

+ (void)completeModel:(CR_SPTIabTCFModel *)model
    withPublisherPurposesTransparencyConsent:(NSString *)segmentString {
  unsigned char *binaryCharBuffer = [[self class] binaryFromString:segmentString];

  if (!binaryCharBuffer) {
    return;
  }

  CR_SPTIabTCFSegmentType segmentType = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                                 fromIndex:0
                                                                    length:SEGMENT_TYPE_BIT_LENGTH];
  if (segmentType != SegmentTypePublisherTC) {
    return;
  }
  model.publisherTCParsedPurposesConsents =
      [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                         fromIndex:PUBLISHER_PURPOSES_CONSENT_BIT_OFFSET
                                            length:PUBLISHER_PURPOSES_CONSENT_BIT_LENGTH];
  model.publisherTCParsedPurposesLegitmateInterest =
      [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                         fromIndex:PUBLISHER_PURPOSES_LEGIT_INTEREST_BIT_OFFSET
                                            length:PUBLISHER_PURPOSES_LEGIT_INTEREST_BIT_LENGTH];

  int variableOffset = PUBLISHER_NUM_CUSTOM_PURPOSES_BIT_OFFSET;
  NSInteger numCustomPurposes =
      [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                               fromIndex:PUBLISHER_NUM_CUSTOM_PURPOSES_BIT_OFFSET
                                  length:PUBLISHER_NUM_CUSTOM_PURPOSES_BIT_LENGTH];
  variableOffset += PUBLISHER_NUM_CUSTOM_PURPOSES_BIT_LENGTH;

  model.publisherTCParsedCustomPurposesConsents =
      [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                         fromIndex:variableOffset
                                            length:(int)numCustomPurposes];
  variableOffset += numCustomPurposes;
  model.publisherTCParsedCustomPurposesLegitmateInterest =
      [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                         fromIndex:variableOffset
                                            length:(int)numCustomPurposes];

  free(binaryCharBuffer);
}

//******************************************************************
#pragma mark--------- Decode IAB Formats ------------
//******************************************************************

+ (NSDate *)decodeDateFromBinary:(unsigned char *)binaryCharBuffer
                       fromIndex:(int)startIndex
                          length:(int)length {
  NSInteger deciSecondsEpoch = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                        fromIndex:startIndex
                                                           length:length];

  return [NSDate dateWithTimeIntervalSince1970:deciSecondsEpoch / 10];
}

+ (NSString *)decode6BitCharStringFromBinary:(unsigned char *)binaryCharBuffer
                                   fromIndex:(int)startIndex
                                      length:(int)length {
  int a = 65;  // first char
  int charBitLenght = 6;
  if (length % charBitLenght != 0) {
    NSDebugLog(
        @"CR_SPTIabConsentStringParser: Invalid 6 bit char encoded string (not a 6 multiple)");
    return @"";
  }
  int characterNumber = length / charBitLenght;
  NSString *result = @"";
  for (int i = 0; i < characterNumber; i++) {
    NSInteger letter = a + [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                    fromIndex:startIndex + charBitLenght * i
                                                       length:charBitLenght];
    result = [NSString stringWithFormat:@"%@%c", result, (char)letter];
  }

  return result;
}

+ (NSString *)decodeBitChainStringFromBinary:(unsigned char *)binaryCharBuffer
                                   fromIndex:(int)startIndex
                                      length:(int)length {
  NSMutableString *bitChainString = [NSMutableString new];
  for (int i = 1; i <= length; i++) {
    NSString *stringAtIndex = @"0";
    size_t binaryLength = (int)strlen((const char *)binaryCharBuffer);
    NSInteger itemId = startIndex + i - 1;
    if (binaryLength <= itemId || itemId > startIndex + length) {
      return @"0";
    }
    stringAtIndex = binaryCharBuffer[itemId] == '1' ? @"1" : @"0";

    [bitChainString appendString:stringAtIndex];
  }
  return bitChainString;
}

+ (SPTDecodedStringAndOffset *)decodeVendorBitChainStringFromBinary:
                                   (unsigned char *)binaryCharBuffer
                                                          fromIndex:(int)startIndex
                                                           version1:(BOOL)v1 {
  int totalOffset = startIndex;

  NSInteger maxVendorId = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                   fromIndex:startIndex
                                                      length:MAX_VENDOR_ID_BIT_LENGTH];
  totalOffset += MAX_VENDOR_ID_BIT_LENGTH;

  SPTDecodedStringAndOffset *vendorVLDS =
      [[self class] decodeBitChainStringFromBinary:binaryCharBuffer
                                         fromIndex:totalOffset
                                       entryNumber:maxVendorId
                                          version1:v1];
  totalOffset += vendorVLDS.offset;

  int localOffset = totalOffset - startIndex;
  vendorVLDS.offset = localOffset;

  return vendorVLDS;
}

+ (SPTDecodedPublisherRestrictionAndOffset *)
    decodePublisherRestrictionBitChainStringFromBinary:(unsigned char *)binaryCharBuffer
                                             fromIndex:(int)startIndex {
  int totalOffset = startIndex;

  NSInteger numPubRestriction =
      [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                               fromIndex:startIndex
                                  length:NUM_PUBLISHER_RESTRICTIONS_BIT_LENGTH];
  totalOffset += NUM_PUBLISHER_RESTRICTIONS_BIT_LENGTH;

  NSMutableArray *pubRestrictions = [[NSMutableArray alloc] initWithCapacity:numPubRestriction];

  for (int i = 0; i < numPubRestriction; i++) {
    NSInteger purposeId =
        [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                 fromIndex:totalOffset
                                    length:PUBLISHER_RESTRICTIONS_PURPOSE_ID_BIT_LENGTH];
    totalOffset += PUBLISHER_RESTRICTIONS_PURPOSE_ID_BIT_LENGTH;

    PublisherRestrictionType restrictType =
        [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                 fromIndex:totalOffset
                                    length:PUBLISHER_RESTRICTION_TYPE_BIT_LENGTH];
    totalOffset += PUBLISHER_RESTRICTION_TYPE_BIT_LENGTH;

    SPTVendorIdsAndOffset *vendorVLDS =
        [[self class] decodeBitChainStringForPubRest:binaryCharBuffer fromIndex:totalOffset];
    totalOffset += vendorVLDS.offset;

    CR_SPTIabPublisherRestriction *pubRestriction = [CR_SPTIabPublisherRestriction new];
    pubRestriction.purposeId = purposeId;
    pubRestriction.retrictionType = restrictType;
    pubRestriction.vendorsIds = vendorVLDS.value;

    [pubRestrictions addObject:pubRestriction];
  }

  int localOffset = totalOffset - startIndex;
  SPTDecodedPublisherRestrictionAndOffset *retVal = [SPTDecodedPublisherRestrictionAndOffset new];
  retVal.offset = localOffset;
  retVal.value = pubRestrictions;

  return retVal;
}

+ (SPTVendorIdsAndOffset *)decodeBitChainStringForPubRest:(unsigned char *)binaryCharBuffer
                                                fromIndex:(int)startIndex {
  int totalOffset = startIndex;

  NSInteger numEntries = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                  fromIndex:totalOffset
                                                     length:NUM_ENTRIES_BIT_LENGTH];
  totalOffset += NUM_ENTRIES_BIT_LENGTH;

  NSMutableArray *vendorConsentIds = [NSMutableArray new];

  for (int i = 0; i < (int)numEntries; i++) {
    BOOL isRangeAndNotSingleEntry = binaryCharBuffer[totalOffset] != '0';
    totalOffset++;
    if (!isRangeAndNotSingleEntry) {
      NSInteger singleVendorId =
          [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                   fromIndex:totalOffset
                                      length:START_OR_ONLY_VENDOR_ID_BIT_LENGTH];
      totalOffset += START_OR_ONLY_VENDOR_ID_BIT_LENGTH;
      [vendorConsentIds addObject:[NSNumber numberWithInteger:singleVendorId]];

    } else {
      NSInteger startVendorId =
          [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                   fromIndex:totalOffset
                                      length:START_OR_ONLY_VENDOR_ID_BIT_LENGTH];
      totalOffset += START_OR_ONLY_VENDOR_ID_BIT_LENGTH;

      NSInteger endVendorId = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                       fromIndex:totalOffset
                                                          length:END_VENDOR_ID_BIT_LENGTH];
      totalOffset += END_VENDOR_ID_BIT_LENGTH;
      for (int i = (int)startVendorId; i <= (int)endVendorId; i++) {
        [vendorConsentIds addObject:[NSNumber numberWithInteger:i]];
      }
    }
  }

  int localOffset = totalOffset - startIndex;
  SPTVendorIdsAndOffset *retvalue = [SPTVendorIdsAndOffset new];
  retvalue.value = vendorConsentIds;
  retvalue.offset = localOffset;

  return retvalue;
}

+ (SPTDecodedStringAndOffset *)decodeBitChainStringFromBinary:(unsigned char *)binaryCharBuffer
                                                    fromIndex:(int)startIndex
                                                  entryNumber:(NSInteger)entryNumber
                                                     version1:(BOOL)v1 {
  int totalOffset = startIndex;

  NSMutableString *retString = [NSMutableString new];

  BOOL isRangeEncoding = binaryCharBuffer[totalOffset] != '0';
  totalOffset++;

  if (!isRangeEncoding) {
    for (int i = 0; i < (int)entryNumber; i++) {
      [retString appendString:[NSString stringWithFormat:@"%c", binaryCharBuffer[totalOffset]]];
      totalOffset++;
    }
  } else {
    BOOL consentByDefault = NO;
    if (v1) {
      consentByDefault = binaryCharBuffer[totalOffset] != '0';
      totalOffset++;
    }

    NSInteger numEntries = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                    fromIndex:totalOffset
                                                       length:NUM_ENTRIES_BIT_LENGTH];
    totalOffset += NUM_ENTRIES_BIT_LENGTH;

    NSMutableArray *vendorConsentIds = [NSMutableArray new];

    for (int i = 0; i < (int)numEntries; i++) {
      BOOL isRangeAndNotSingleEntry = binaryCharBuffer[totalOffset] != '0';
      totalOffset++;
      if (!isRangeAndNotSingleEntry) {
        NSInteger singleVendorId =
            [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                     fromIndex:totalOffset
                                        length:START_OR_ONLY_VENDOR_ID_BIT_LENGTH];
        totalOffset += START_OR_ONLY_VENDOR_ID_BIT_LENGTH;
        [vendorConsentIds addObject:[NSNumber numberWithInteger:singleVendorId]];

      } else {
        NSInteger startVendorId =
            [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                     fromIndex:totalOffset
                                        length:START_OR_ONLY_VENDOR_ID_BIT_LENGTH];
        totalOffset += START_OR_ONLY_VENDOR_ID_BIT_LENGTH;

        NSInteger endVendorId = [CR_SPTIabTCFUtils BinaryToDecimal:binaryCharBuffer
                                                         fromIndex:totalOffset
                                                            length:END_VENDOR_ID_BIT_LENGTH];
        totalOffset += END_VENDOR_ID_BIT_LENGTH;
        for (int i = (int)startVendorId; i <= (int)endVendorId; i++) {
          [vendorConsentIds addObject:[NSNumber numberWithInteger:i]];
        }
      }
    }

    for (int i = 1; i <= (int)entryNumber; i++) {
      if ([vendorConsentIds containsObject:[NSNumber numberWithInteger:i]]) {
        [retString appendString:!consentByDefault ? @"1" : @"0"];
      } else {
        [retString appendString:!consentByDefault ? @"0" : @"1"];
      }
    }
  }

  int localOffset = totalOffset - startIndex;
  SPTDecodedStringAndOffset *retvalue = [SPTDecodedStringAndOffset new];
  retvalue.value = retString;
  retvalue.offset = localOffset;

  return retvalue;
}

//******************************************************************
#pragma mark--------- Binary Base 64 String ------------
//******************************************************************

+ (unsigned char *)binaryFromString:(NSString *)consentString {
  NSString *safeString = [CR_SPTIabTCFUtils safeBase64ConsentString:consentString];
  NSData *decodedData =
      [[NSData alloc] initWithBase64EncodedString:safeString
                                          options:NSDataBase64DecodingIgnoreUnknownCharacters];

  if (!decodedData) {
    return nil;
  }

  return [CR_SPTIabTCFUtils NSDataToBinary:decodedData];
}

@end
