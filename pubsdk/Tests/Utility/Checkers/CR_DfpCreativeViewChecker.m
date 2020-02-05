//
// Created by Aleksandr Pakhmutov on 10/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_DfpCreativeViewChecker.h"
#import "UIView+Testing.h"
#import "UIWebView+Testing.h"
#import "Logging.h"
#import "CR_Timer.h"
#import "CR_ViewCheckingHelper.h"
#import "Criteo+Testing.h"
#import "CR_TestAdUnits.h"

@interface CR_DfpCreativeViewChecker ()

@property (nonatomic, strong) NSMutableArray<XCTAttachment *> *attachmentArray;

@end


@implementation CR_DfpCreativeViewChecker {
    NSString *expectedCreative;
}

-(instancetype)initWithAdUnitId:(NSString *)adUnitId {
    if (self = [super init]) {
        _attachmentArray = [[NSMutableArray alloc] init];
        _adCreativeRenderedExpectation = [[XCTestExpectation alloc] initWithDescription:@"Expect that Criteo creative appears."];
        _adCreativeRenderedExpectationWithoutExpectedCreative = [[XCTestExpectation alloc] initWithDescription:@"Expect that Criteo creative appears without expected creative."];
        _uiWindow = [self createUIWindow];
        expectedCreative = adUnitId == [CR_TestAdUnits dfpNativeId]
            ? [CR_ViewCheckingHelper preprodCreativeImageUrlForNative]
            : [CR_ViewCheckingHelper preprodCreativeImageUrl];
    }
    return self;
}

-(instancetype)initWithBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId {
    if ([self initWithAdUnitId:adUnitId]) {
        _dfpBannerView = [self createDfpBannerWithSize:size withAdUnitId:adUnitId];
        _dfpBannerView.delegate = self;
        _dfpBannerView.rootViewController = _uiWindow.rootViewController;
        [self.uiWindow.rootViewController.view addSubview:_dfpBannerView];
    }
    return self;
}

-(instancetype)initWithInterstitial:(DFPInterstitial *)dfpInterstitial {
    if ([self initWithAdUnitId:dfpInterstitial.adUnitID]) {
        dfpInterstitial.delegate = self;
    }
    return self;
}

-(BOOL)waitAdCreativeRendered {
    return [self waitAdCreativeRenderedWithTimeout:10.];
}

-(BOOL)waitAdCreativeRenderedWithTimeout:(NSTimeInterval)timeout {
    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    XCTWaiterResult result = [waiter waitForExpectations:@[self.adCreativeRenderedExpectation]
                                                 timeout:timeout];
    return (result == XCTWaiterResultCompleted);
}

- (NSArray<XCTAttachment *> *)attachments {
    return [self.attachmentArray copy];
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [self _insertScreenshotAttachement];
    [self checkViewAndFulfillExpectation];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    [self _insertScreenshotAttachement];
    CLog(@"[ERROR] CR_DfpBannerViewChecker.GADBannerViewDelegate (didFailToReceiveAdWithError) %@", error.description);
}

#pragma mark - GADInterstitialDelegate methods

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [ad presentFromRootViewController:self.uiWindow.rootViewController];
    [self _insertScreenshotAttachement];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [CR_Timer scheduledTimerWithTimeInterval:1
                                     repeats:NO
                                       block:^(NSTimer * _Nonnull timer) {
                                          [self checkViewAndFulfillExpectation];
                                      }];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    [self _insertScreenshotAttachement];
    CLog(@"[ERROR] CR_DfpBannerViewChecker.GADInterstitialDelegate (didFailToReceiveAdWithError) %@", error.description);
}

#pragma mark - Private methods

- (void)checkViewAndFulfillExpectation {
    [self _insertScreenshotAttachement];
    UIWebView *firstWebView = [self.uiWindow testing_findFirstWebView];
    NSString *htmlContent = [firstWebView testing_getHtmlContent];
    NSLog(@"EXP CR : %@", expectedCreative);
    if ([htmlContent containsString:expectedCreative]) {
        [self.adCreativeRenderedExpectation fulfill];
    } else {
        [self.adCreativeRenderedExpectationWithoutExpectedCreative fulfill];
    }
    self.uiWindow.hidden = YES;
}

- (UIWindow *)createUIWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 50, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *viewController = [UIViewController new];
    window.rootViewController = viewController;
    return window;
}

-(DFPBannerView *)createDfpBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId {
    DFPBannerView *dfpBannerView = [[DFPBannerView alloc] initWithAdSize:size];
    dfpBannerView.adUnitID = adUnitId;
    dfpBannerView.backgroundColor = [UIColor orangeColor];
    return dfpBannerView;
}

- (void)_insertScreenshotAttachement {
    UIImage *screenshot = [self _screenshotWindow];
    XCTAttachment *attachement = [XCTAttachment attachmentWithImage:screenshot];
    [self.attachmentArray addObject:attachement];
}

- (UIImage *)_screenshotWindow {
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, false, [UIScreen mainScreen].scale);
    [self.uiWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
