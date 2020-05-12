//
//  CR_MopubAsserts.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_TargetingKeys.h"

#ifndef CR_AssertMopub_h
#define CR_AssertMopub_h

#define CR_AssertMopubKeywordContainsCriteoBid(keywords, initialKeywords, displayUrl) \
    XCTAssertTrue([keywords containsString:initialKeywords]); \
    XCTAssertTrue([keywords containsString:[CR_TargetingKey_crtCpm stringByAppendingString:@":20.00"]]); \
    XCTAssertTrue([keywords containsString:[[CR_TargetingKey_crtDisplayUrl stringByAppendingString:@":"] stringByAppendingString:displayUrl]]);

#endif /* CR_AssertMopub_h */