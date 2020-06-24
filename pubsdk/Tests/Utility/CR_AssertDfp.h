//
//  CR_AssertDfp.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef CR_AssertDfp_h
#define CR_AssertDfp_h

#define CR_AssertDfpCustomTargetingContainsCriteoBid(customTargeting)      \
  XCTAssertEqualObjects(customTargeting[CR_TargetingKey_crtCpm], @"1.12"); \
  XCTAssertNotNil(customTargeting[CR_TargetingKey_crtDfpDisplayUrl]);

#endif /* CR_AssertDfp_h */
