//
//  CR_NetworkSessionPlayer.m
//  CriteoPublisherSdkTests
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

#import "CR_ApiQueryKeys.h"
#import "CR_Config.h"
#import "CR_NetworkManagerSimulator.h"
#import "CR_ThreadManager.h"
#import "Criteo+Testing.h"
#import "NSURL+Testing.h"
#import "CR_ViewCheckingHelper.h"

NSString *const CR_NetworkManagerSimulatorDefaultDisplayUrl =
    @"https://localhost:9099/cdb-stubs/delivery/ajs.php?width=320&height=50";

NSString *const CR_NetworkManagerSimulatorDefaultCpm = @"1.12";

NSString *const CR_NetworkSessionReplayerKillSwitchFalse =
    @"{\"killSwitch\":false,\"AndroidDisplayUrlMacro\":\"%%displayUrl%%\",\"AndroidAdTagUrlMode\":\"<html><body style='text-align:center; margin:0px; padding:0px; horizontal-align:center;'><script src=\\\"%%displayUrl%%\\\"></script></body></html>\",\"AndroidAdTagDataMacro\":\"%%adTagData%%\",\"AndroidAdTagDataMode\":\"<html><body style='text-align:center; margin:0px; padding:0px; horizontal-align:center;'><script>%%adTagData%%</script></body></html>\",\"iOSDisplayUrlMacro\":\"%%displayUrl%%\",\"iOSWidthMacro\":\"%%width%%\",\"iOSAdTagUrlMode\":\"<!doctype html><html><head><meta charset=\\\"utf-8\\\"><style>body{margin:0;padding:0}</style><meta name=\\\"viewport\\\" content=\\\"width=%%width%%, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\\\" ></head><body><script src=\\\"%%displayUrl%%\\\"></script></body></html>\"}";

NSString *const CR_NetworkSessionReplayerGumReponse = @"{\"throttleSec\":5}";

NSString *const CR_NetworkSessionEmptyBid =
    @"{\"slots\":[],\"requestId\":\"c412223b-7c6b-4754-931c-708925e5ce4d\"}";

@interface CR_NetworkManagerSimulator ()

@property(nonatomic, strong, readonly) CR_Config *config;
@property(nonatomic, assign, readonly) NSTimeInterval delay;

@end

@implementation CR_NetworkManagerSimulator

#pragma mark - Properties

+ (NSTimeInterval)interstitialTtl {
  return 3600;
}

#pragma mark - Lifecycle

- (instancetype)initWithConfig:(CR_Config *)config delay:(NSTimeInterval)delay {
  // FIXME EE-1228 This is a different implementation and network manager should be a protocol. This
  // would
  //  allow to not mess up constructor like this.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  self = [super initWithDeviceInfo:nil session:nil threadManager:nil];
#pragma clang diagnostic pop

  if (self) {
    _config = config;
    _delay = delay;
  }
  return self;
}

#pragma mark - Network Manager overrides

- (void)getFromUrl:(NSURL *)url responseHandler:(CR_NMResponse)responseHandler {
  if (!responseHandler) return;
  if (self.delay) [NSThread sleepForTimeInterval:self.delay];

  if ([url.scheme isEqualToString:@"file"]) {
    [super getFromUrl:url responseHandler:responseHandler];
  } else if ([url testing_isAppEventUrlWithConfig:self.config]) {
    NSData *response = [CR_NetworkSessionReplayerGumReponse dataUsingEncoding:NSUTF8StringEncoding];
    responseHandler(response, nil);
  } else if ([url testing_isNativeProductImage]) {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *imageUrl = [bundle URLForResource:@"image" withExtension:@"png"];
    NSData *response = [NSData dataWithContentsOfURL:imageUrl];
    responseHandler(response, nil);
  } else if ([url testing_isNativeAdvertiserLogoImage]) {
    // CDB preprod return an SVG
    NSString *svg =
        @"<svg height=\"100\" width=\"100\">\n"
         "<circle cx=\"50\" cy=\"50\" r=\"40\" stroke=\"black\" stroke-width=\"3\" fill=\"red\" />\n"
         "</svg>";
    NSData *response = [svg dataUsingEncoding:NSUTF8StringEncoding];
    responseHandler(response, nil);
  } else if ([url testing_isNativeAdChoiceImage]) {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *imageUrl = [bundle URLForResource:@"image" withExtension:@"jpeg"];
    NSData *response = [NSData dataWithContentsOfURL:imageUrl];
    responseHandler(response, nil);
  } else if ([url testing_isNativeAdImpressionPixel]) {
    responseHandler(nil, nil);
  } else {
    NSAssert(NO, @"Unknown URL in GET: %@", url);
  }
}

- (void)postToUrl:(NSURL *)url
               body:(id)body
         logWithTag:(NSString *_Nullable)logTag
    responseHandler:(nullable CR_NMResponse)responseHandler {
  if (!responseHandler) return;
  if (self.delay) [NSThread sleepForTimeInterval:self.delay];

  if ([url testing_isBidUrlWithConfig:self.config]) {
    NSError *error = NULL;
    NSData *response = [self handleBidRequestWithUrl:url postBody:body error:&error];
    responseHandler(response, error);
    return;
  }

  if ([url testing_isFeedbackMessageUrlWithConfig:self.config]) {
    responseHandler(nil, nil);
    return;
  }

  if ([url testing_isConfigUrlWithConfig:self.config]) {
    NSData *response =
        [CR_NetworkSessionReplayerKillSwitchFalse dataUsingEncoding:NSUTF8StringEncoding];
    responseHandler(response, nil);
    return;
  }

  NSAssert(NO, @"Unknown URL in POST: %@\nBody: %@", url, body);
}

#pragma mark - Private

- (NSData *)handleBidRequestWithUrl:(NSURL *)url
                           postBody:(NSDictionary *)postBody
                              error:(NSError **)error {
  NSArray *slots = postBody[CR_ApiQueryKeys.bidSlots];
  NSMutableArray *slotResponses = [[NSMutableArray alloc] init];
  for (NSDictionary *slot in slots) {
    NSDictionary *slotResponseDict = [self slotResponseForPayload:slot];
    if (slotResponseDict) {
      NSString *slotResponse = [self stringFromSlotResponseDictionary:slotResponseDict];
      [slotResponses addObject:slotResponse];
    }
  }

  if (slotResponses.count == 0) {
    return [CR_NetworkSessionEmptyBid dataUsingEncoding:NSUTF8StringEncoding];
  }

  NSString *joinedSlots = [slotResponses componentsJoinedByString:@","];
  NSString *response = [[NSString alloc]
      initWithFormat:@"{\"slots\":[%@],\"requestId\":\"c412223b-7c6b-4754-931c-708925e5ce4d\"}",
                     joinedSlots];
  return [response dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)slotResponseForPayload:(NSDictionary *)payload {
  NSString *placementId = payload[CR_ApiQueryKeys.bidSlotsPlacementId];

  if ([placementId isEqualToString:DemoInterstitialAdUnitId] ||
      [placementId isEqualToString:PreprodInterstitialAdUnitId]) {
    NSDictionary *result = [self interstitialSlotResponseForPayload:payload];
    return result;
  }

  if ([placementId isEqualToString:PreprodBannerAdUnitId] ||
      [placementId isEqualToString:DemoBannerAdUnitId]) {
    NSDictionary *result = [self bannerSlotResponseForPayload:payload];
    return result;
  }

  if ([placementId isEqualToString:PreprodNativeAdUnitId]) {
    NSDictionary *result = [self nativeSlotReponseForPayload:payload];
    return result;
  }

  return nil;
}

- (NSDictionary *)nativeSlotReponseForPayload:(NSDictionary *)payload {
  NSDictionary *native = @{
    @"products" : @[ @{
      @"title" : @"Criteo native solution",
      @"description" : @"A smart solution for your Native advertising",
      @"price" : @"10$",
      @"clickUrl" : @"https://www.criteo.com/products/",
      @"callToAction" : @"Try it now!",
      @"image" : @{
        @"url" : @"https://publisherdirect.criteo.com/publishertag/preprodtest/creative.png",
        @"height" : @300,
        @"width" : @300
      }
    } ],
    @"advertiser" : @{
      @"description" : @"Our digital marketing solutions are trusted",
      @"domain" : @"criteo.com",
      @"logo" : @{
        @"url" : @"https://www.criteo.com/images/criteo-logo.svg",
        @"height" : @300,
        @"width" : @300
      },
      @"logoClickUrl" : @"https://www.criteo.com",
    },
    @"privacy" : @{
      @"optoutClickUrl" : @"https://info.criteo.com/privacy/informations",
      @"optoutImageUrl" : @"https://static.criteo.net/flash/icon/nai_small.png",
      @"longLegalText" : @"Long Legal Text"
    },
    @"impressionPixels" : @[
      @{@"url" : @"https://my-impression-pixel/test/impression"},
      @{@"url" : @"https://cas.com/lg.com"}
    ]
  };

  NSMutableDictionary *dict = [[self defaultSlotResponseForPayload:payload] mutableCopy];
  dict[@"width"] = @2;
  dict[@"height"] = @2;
  dict[@"native"] = native;
  return dict;
}

- (NSDictionary *)bannerSlotResponseForPayload:(NSDictionary *)payload {
  NSMutableDictionary *dict = [[self defaultSlotResponseForPayload:payload] mutableCopy];
  CGSize size = [self sizeFromSlotSize:payload[@"sizes"][0]];
  dict[@"width"] = @((int)size.width);
  dict[@"height"] = @((int)size.height);
  dict[@"displayUrl"] = CR_NetworkManagerSimulatorDefaultDisplayUrl;
  return dict;
}

- (NSDictionary *)interstitialSlotResponseForPayload:(NSDictionary *)payload {
  NSArray *sizes = payload[CR_ApiQueryKeys.bidSlotsSizes];
  const CGSize size = [self sizeFromSlotSize:sizes[0]];

  NSMutableDictionary *dict = [[self defaultSlotResponseForPayload:payload] mutableCopy];
  dict[@"width"] = @(size.width);
  dict[@"height"] = @(size.height);
  dict[@"ttl"] = @(self.class.interstitialTtl);
  dict[@"displayUrl"] = CR_ViewCheckingHelper.preprodCreativeImageUrl;
  return dict;
}

- (NSDictionary *)defaultSlotResponseForPayload:(NSDictionary *)payload {
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  dict[@"impId"] = payload[@"impId"];
  dict[@"placementId"] = payload[@"placementId"];
  dict[@"arbitrageId"] = [[NSString alloc] initWithFormat:@"arbitrage-%@", payload[@"placementId"]];
  dict[@"zoneId"] = @25742;
  dict[@"cpm"] = CR_NetworkManagerSimulatorDefaultCpm;
  dict[@"currency"] = @"USD";
  dict[@"ttl"] = @0;
  return dict;
}

- (CGSize)sizeFromSlotSize:(NSString *)slotSize {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  formatter.numberStyle = NSNumberFormatterDecimalStyle;
  NSArray *firstSizeSplit = [slotSize componentsSeparatedByString:@"x"];
  NSNumber *width = [formatter numberFromString:firstSizeSplit[0]];
  NSNumber *height = [formatter numberFromString:firstSizeSplit[1]];
  CGSize size = {[width floatValue], [height floatValue]};
  return size;
}

- (NSString *)stringFromSlotResponseDictionary:(NSDictionary *)slotResponseDictionary {
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:slotResponseDictionary
                                                 options:0
                                                   error:&error];
  NSAssert(!error, @"Error %@", error);
  NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return result;
}

- (CGSize)sizeForStringSize:(NSString *)sizeStr {
  NSArray *split = [sizeStr componentsSeparatedByString:@"x"];
  NSAssert(split.count == 2, @"%@ should be of the form \"<integer>x<integer>\"", sizeStr);
  CGSize size = (CGSize){[split[0] floatValue], [split[1] floatValue]};
  return size;
}

@end
