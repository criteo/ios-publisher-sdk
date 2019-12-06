//
//  CR_MopubAsserts.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_AssertMopub_h
#define CR_AssertMopub_h

#define CR_AssertMopubKeywordContainsCriteoBid(keywords, initialKeywords) \
    XCTAssertTrue([keywords containsString:initialKeywords]); \
    XCTAssertTrue([keywords containsString:@"crt_cpm:20.00"]); \
    XCTAssertTrue([keywords containsString:@"crt_displayUrl:"]);

#endif /* CR_AssertMopub_h */
