//
// Created by Aleksandr Pakhmutov on 03/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "CR_IntegrationsTestBase.h"
#import "Criteo+Testing.h"


@implementation CR_IntegrationsTestBase

- (void)initCriteoWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    [self.criteo testing_registerAndWaitForHTTPResponseWithAdUnits:adUnits];
}

- (NSString *)getDecodedDisplayUrlFromDfpRequestCustomTargeting:(NSDictionary *)customTargeting {
    NSString *encodedUrl = customTargeting[@"crt_displayurl"];
    NSString *unescapedUrl = [[encodedUrl stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:unescapedUrl options:0];
    NSString *decodedUrl = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedUrl;
}

@end
