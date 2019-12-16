//
//  CR_MopubAsserts.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_TargetingKeys.h"

#ifndef CR_AssertMopub_h
#define CR_AssertMopub_h

#define CR_AssertMopubKeywordContainsCriteoBid(keywords, initialKeywords, displayUrl) \
    XCTAssertTrue([keywords containsString:initialKeywords]); \
    XCTAssertTrue([keywords containsString:[CR_TargetingKey_crtCpm stringByAppendingString:@":20.00"]]); \
    XCTAssertTrue([keywords containsString:[[CR_TargetingKey_crtDisplayUrl stringByAppendingString:@":"] stringByAppendingString:displayUrl]]);

#endif /* CR_AssertMopub_h */
