//
// Created by Aleksandr Pakhmutov on 03/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "CR_IntegrationsTestBase.h"
#import "Criteo+Testing.h"
#import "CR_NetworkCaptor.h"


@implementation CR_IntegrationsTestBase

- (void)setUp {
    [super setUp];

    self.criteo = nil;
}

- (void)tearDown {
    NSArray<CR_HttpContent *> *requests = self.criteo.testing_networkCaptor.allRequests;
    for (NSUInteger count = 0; count < requests.count; count++) {
        CR_HttpContent *r = requests[count];
        NSString *filename = [[NSString alloc] initWithFormat:@"HTTPRequest_%lu_%@_%@.txt", (unsigned long)count, NSStringFromHTTPVerb(r.verb), r.url];
        NSData *data = [r.description dataUsingEncoding:NSUTF8StringEncoding];

        XCTAttachment *att = [[XCTAttachment alloc] initWithUniformTypeIdentifier:@"public.utf8-plain-text"
                                                                             name:filename
                                                                          payload:data
                                                                         userInfo:nil];
        [self addAttachment:att];
    }
    
    [super tearDown];
}

- (void)initCriteoWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    [self.criteo testing_registerAndWaitForHTTPResponseWithAdUnits:adUnits];
}

@end
