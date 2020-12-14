//
//  CR_URLOpener.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <StoreKit/StoreKit.h>

#import "Criteo+Internal.h"
#import "CR_DependencyProvider.h"
#import "CR_URLOpener.h"
#import "CR_URLResolver.h"
#import "CR_SKAdNetworkParameters.h"
#import "CR_Logging.h"
#import "UIView+Criteo.h"
#import "CR_Logging.h"

@interface CR_URLOpener () <SKStoreProductViewControllerDelegate>
@property(nonatomic, readonly) CR_DeviceInfo *deviceInfo;
@property(nonatomic, strong) SKStoreProductViewController *storeKitController;
@end

@implementation CR_URLOpener

- (void)openExternalURL:(NSURL *)url withCompletion:(CR_URLOpeningCompletion)completion {
  if (@available(iOS 10, *)) {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:completion];
  } else if (completion) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    completion([[UIApplication sharedApplication] openURL:url]);
#pragma clang diagnostic pop
  }
}

- (void)openExternalURL:(NSURL *)URL
    withSKAdNetworkParameters:(CR_SKAdNetworkParameters *_Nullable)parameters
           fromViewController:(UIViewController *)controller
                   completion:(CR_URLOpeningCompletion)completion {
  if (@available(iOS 14, *)) {
    NSDictionary *loadProductParameters = parameters.toLoadProductParameters;
    if (loadProductParameters != nil && self.storeKitController == nil) {
      CR_URLResolver *resolver = [[CR_URLResolver alloc] init];
      [resolver resolverURL:URL
                 deviceInfo:self.deviceInfo
                 resolution:^(CR_URLResolution *resolution) {
                   switch (resolution.type) {
                     case CR_URLResolutionStandardUrl:
                       [self openExternalURL:resolution.URL withCompletion:completion];
                       break;
                     case CR_URLResolutionAppStoreUrl:
                       [self presentStoreKitControllerWithProductParameters:loadProductParameters
                                                         fromViewController:controller
                                                             withCompletion:completion];
                       break;
                     default:
                       CRLogWarn(@"URLOpen", @"Cannot open URL: %@", URL);
                       break;
                   }
                 }];
    } else {
      [self openExternalURL:URL withCompletion:completion];
    }
  } else {
    [self openExternalURL:URL withCompletion:completion];
  }
}

- (void)openExternalURL:(NSURL *)url
    withSKAdNetworkParameters:(CR_SKAdNetworkParameters *)parameters
                     fromView:(UIView *)view
                   completion:(CR_URLOpeningCompletion)completion {
  [self openExternalURL:url
      withSKAdNetworkParameters:parameters
             fromViewController:[view cr_parentViewController]
                     completion:completion];
}

#pragma mark - Private

- (CR_DeviceInfo *)deviceInfo {
  return Criteo.sharedCriteo.dependencyProvider.deviceInfo;
}

- (void)presentStoreKitControllerWithProductParameters:(NSDictionary *)parameters
                                    fromViewController:(UIViewController *)controller
                                        withCompletion:(CR_URLOpeningCompletion)completion {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.storeKitController = [[SKStoreProductViewController alloc] init];
    self.storeKitController.modalPresentationStyle = UIModalPresentationFullScreen;
    self.storeKitController.delegate = self;
    [self.storeKitController loadProductWithParameters:parameters completionBlock:nil];
    [controller
        presentViewController:self.storeKitController
                     animated:YES
                   completion:^{
                     CRLogInfo(@"SKAdNetwork", @"Loaded product with parameters: %@", parameters);
                     completion(YES);
                   }];
  });
}

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  self.storeKitController = nil;
}

@end
