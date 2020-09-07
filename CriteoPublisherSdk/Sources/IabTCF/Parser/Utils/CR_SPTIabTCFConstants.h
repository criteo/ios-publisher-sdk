//
//  CR_SPTIabTCFConstants.h
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 04/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef CMPConsentConstant_h
#define CMPConsentConstant_h

//******************************************************************
#pragma mark--------- V 1  &  V 2 --------
//******************************************************************
static int VERSION_BIT_OFFSET = 0;
static int VERSION_BIT_LENGTH = 6;

static int CREATED_BIT_OFFSET = 6;
static int CREATED_BIT_LENGTH = 36;

static int LAST_UPDATED_BIT_OFFSET = 42;
static int LAST_UPDATED_BIT_LENGTH = 36;

static int CMP_ID_BIT_OFFSET = 78;
static int CMP_ID_BIT_LENGTH = 12;

static int CMP_VERSION_BIT_OFFSET = 90;
static int CMP_VERSION_BIT_LENGTH = 12;

static int CONSENT_SCREEN_BIT_OFFSET = 102;
static int CONSENT_SCREEN_BIT_LENGTH = 6;

static int CONSENT_LANGUAGE_BIT_OFFSET = 108;
static int CONSENT_LANGUAGE_BIT_LENGTH = 12;

static int VENDOR_LIST_VERSION_BIT_OFFSET = 120;
static int VENDOR_LIST_VERSION_BIT_LENGTH = 12;

#pragma mark Variable Length
static int MAX_VENDOR_ID_BIT_LENGTH = 16;
static int NUM_ENTRIES_BIT_LENGTH = 12;
static int START_OR_ONLY_VENDOR_ID_BIT_LENGTH = 16;
static int END_VENDOR_ID_BIT_LENGTH = 16;

//******************************************************************
#pragma mark--------- V 1 ------------
//******************************************************************
static int PURPOSES_ALLOWED_V1_BIT_OFFSET = 132;
static int PURPOSES_ALLOWED_V1_BIT_LENGTH = 24;
static int MAX_VENDOR_ID_V1_BIT_OFFSET = 156;

//******************************************************************
#pragma mark--------- V 2 ------------
//******************************************************************
static int POLICY_VERSION_BIT_OFFSET = 132;
static int POLICY_VERSION_BIT_LENGTH = 6;

static int IS_SERVICE_SPECIFIC_BIT = 138;

static int USE_NON_STANDART_STACK_BIT = 139;

static int SPECIAL_FEATURE_OPTINS_BIT_OFFSET = 140;
static int SPECIAL_FEATURE_OPTINS_BIT_LENGHT = 12;

static int PURPOSES_CONSENT_V2_BIT_OFFSET = 152;
static int PURPOSES_CONSENT_V2_BIT_LENGTH = 24;

static int PURPOSES_LEGIT_INTEREST_BIT_OFFSET = 176;
static int PURPOSES_LEGIT_INTEREST_BIT_LENGTH = 24;

static int PURPOSE_ONE_TREATMENT_BIT = 200;

static int PUBLISHER_COUNTRY_CODE_BIT_OFFSET = 201;
static int PUBLISHER_COUNTRY_CODE_BIT_LENGTH = 12;

static int MAX_VENDOR_ID_V2_BIT_OFFSET = 213;

static int NUM_PUBLISHER_RESTRICTIONS_BIT_LENGTH = 12;
static int PUBLISHER_RESTRICTIONS_PURPOSE_ID_BIT_LENGTH = 6;
static int PUBLISHER_RESTRICTION_TYPE_BIT_LENGTH = 2;

#pragma mark Disclosed Vendors & Allowed Vendors
static int SEGMENT_TYPE_BIT_LENGTH = 3;

#pragma mark Publisher TC
static int PUBLISHER_PURPOSES_CONSENT_BIT_OFFSET = 3;
static int PUBLISHER_PURPOSES_CONSENT_BIT_LENGTH = 24;

static int PUBLISHER_PURPOSES_LEGIT_INTEREST_BIT_OFFSET = 27;
static int PUBLISHER_PURPOSES_LEGIT_INTEREST_BIT_LENGTH = 24;

static int PUBLISHER_NUM_CUSTOM_PURPOSES_BIT_OFFSET = 51;
static int PUBLISHER_NUM_CUSTOM_PURPOSES_BIT_LENGTH = 6;

// static NSArray *v1 = @[@6, @36, @36, @12, @12, @6, @12, @12, @24, @16, @1,
// @1, @[@12,@1,@16,@16,@16]];

#endif /* CMPConsentConstant_h */
