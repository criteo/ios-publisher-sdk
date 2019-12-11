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

- (UIViewController *)createRootViewControllerWithSize:(CGSize)size {

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 50, size.width, size.height)];
    [window makeKeyAndVisible];
    UIViewController *viewController = [UIViewController new];
    window.rootViewController = viewController;
    return viewController;
}

- (NSString *)getDecodedDisplayUrlFromDfpRequestCustomTargeting:(NSDictionary *)customTargeting {
    NSString *encodedUrl = customTargeting[@"crt_displayurl"];
    NSString *unescapedUrl = [[encodedUrl stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:unescapedUrl options:0];
    NSString *decodedUrl = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedUrl;
}

@end
