//
//  GoogleDFPTableViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "GoogleDFPTableViewController.h"

#import <Foundation/Foundation.h>
@import GoogleMobileAds;

#import "Criteo+Internal.h"

@interface GoogleDFPTableViewController ()

@property (nonatomic) DFPBannerView *dfpBannerView;
@property (nonatomic) DFPInterstitial *dfpInterstitial;
@property (nonatomic) UIView *redView;
@property (nonatomic) UITextView *errorTextView;
@property BOOL registeredAdUnit;

@end

@implementation GoogleDFPTableViewController

// Criteo NetworkManagerDelegate Implementation
- (void) networkManager:(NetworkManager*)manager sentRequest:(NSURLRequest*)request
{
    _textFeedback.text = @"";

    NSString *body = nil;

    if (request.HTTPBody) {
        body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    }

    _textFeedback.text = [_textFeedback.text stringByAppendingFormat:@"REQ:\n%@ %@\nHeaders: %@\nBody: %@",
                          request.HTTPMethod,
                          request.URL,
                          request.allHTTPHeaderFields,
                          body];
}

- (void) networkManager:(NetworkManager*)manager
       receivedResponse:(NSURLResponse*)response
               withData:(NSData*)data
                  error:(NSError*)error
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

    if (error)
    {
        _textFeedback.text = [_textFeedback.text stringByAppendingFormat:@"\n\nRESP:\nError: %@\nReason: %@",
                              error.localizedDescription,
                              error.localizedFailureReason];

        if (httpResponse) {
            _textFeedback.text = [_textFeedback.text stringByAppendingFormat:@"\nStatus: %ld %@",
                                  (long)httpResponse.statusCode,
                                  [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
        }

        return;
    }

    NSString *body = nil;

    if (data) {
        body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    _textFeedback.text = [_textFeedback.text stringByAppendingFormat:@"\n\nRESP:\nStatus: %ld %@\nBody: %@",
                          (long)httpResponse.statusCode,
                          [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode],
                          body];
}

- (void)adView:(nonnull GADBannerView *)bannerView
didFailToReceiveAdWithError:(nonnull GADRequestError *)error
{
    NSLog(@"ERROR Receiving Ad: %@", error);

    [self.dfpBannerView removeFromSuperview];

    self.errorTextView = [[UITextView alloc] initWithFrame:self.dfpBannerView.frame];
    self.errorTextView.text = error.description;
    self.errorTextView.backgroundColor = [UIColor clearColor];
    self.errorTextView.textColor = [UIColor whiteColor];

     [self.redView addSubview:self.errorTextView];
}

- (void) resetDfpBannerView {
    if (self.dfpBannerView) {
        [self.dfpBannerView removeFromSuperview];
        self.dfpBannerView = nil;
    }

    if (self.errorTextView) {
        [self.errorTextView removeFromSuperview];
        self.errorTextView = nil;
    }

    if (self.redView) {
        [self.redView removeFromSuperview];
        self.redView = nil;
    }

    self.dfpBannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.dfpBannerView.rootViewController = self;
    self.dfpBannerView.delegate = (id<GADBannerViewDelegate>)self;

    [self addBannerViewToView:self.dfpBannerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //self.dfpBannerView.adUnitID = @"/6499/example/banner";
    //self.dfpBannerView.rootViewController = self;

    Criteo *criteo = [Criteo sharedCriteo];
    _criteoSdk = criteo;

    self.bannerInterstitialSwitch.on = NO;
    [self clearUserDefaults];
    self.gdprSwitch.on = YES;
    [self setGdpr:self.gdprSwitch.on];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self clearUserDefaults];
}

- (void)addBannerViewToView:(UIView *)bannerView {
    CGRect viewFrame = self.view.frame;

    CGRect bannerViewFrame = bannerView.frame;
    bannerViewFrame.origin.x = (viewFrame.size.width - bannerViewFrame.size.width) / 2;

    self.redView = [[UIView alloc] initWithFrame:bannerViewFrame];
    self.redView.backgroundColor = [UIColor redColor];
    [self.redView addSubview:bannerView];

    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.redView];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.redView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomLayoutGuide
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.redView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]
                                ]];
}

# pragma mark - actions

- (IBAction)registerAdUnitClick:(id)sender {
    [self.criteoSdk registerCriteoPublisherId:@"" withAdUnits:[self createAdUnits]];
    _criteoSdk.networkMangerDelegate = self;    // NetworkManager doesn't exist until you register now
    //self.dfpBannerView.adUnitID = @"/140800857/Endeavour_320x50";
    [self.textFeedback setText:@"AdUnit registered!"];
    self->_registeredAdUnit = YES;
}

- (IBAction)bannerInterstitialSwitched:(id)sender {
    if(self.bannerInterstitialSwitch.on) {
        // Interstitial mode
        self.textAdUnitId.text = @"/140800857/Endeavour_Interstitial_320x480";
        self.textAdUnitWidth.text = @"320";
        self.textAdUnitHeight.text = @"480";
    } else {
        // Banner mode
        self.textAdUnitId.text = @"/140800857/Endeavour_320x50";
        self.textAdUnitWidth.text = @"320";
        self.textAdUnitHeight.text = @"50";
    }
}

- (IBAction)gdprSwitched:(id)sender {
    [self setGdpr:self.gdprSwitch.on];
}

- (void) setGdpr:(BOOL)applies {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(applies) forKey:@"IABConsent_SubjectToGDPR"];
    if(applies) {
        [userDefaults setValue:@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA"
                        forKey:@"IABConsent_ConsentString"];
        //Criteo is at 91
        [userDefaults setValue:@"0000000000000010000000000000000000000100000000000000000000000000000000000000000000000000001"
                        forKey:@"IABConsent_ParsedVendorConsents"];
    } else {
        [userDefaults removeObjectForKey:@"IABConsent_ConsentString"];
        [userDefaults removeObjectForKey:@"IABConsent_ParsedVendorConsents"];
    }
}

- (void) clearUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"IABConsent_SubjectToGDPR"];
    [userDefaults removeObjectForKey:@"IABConsent_ConsentString"];
    [userDefaults removeObjectForKey:@"IABConsent_ParsedVendorConsents"];
}

- (NSArray<CRAdUnit*>*) createAdUnits
{
    NSString *adUnitId = self.textAdUnitId.text;
    double width = [self.textAdUnitWidth.text doubleValue];
    double height = [self.textAdUnitHeight.text doubleValue];
    CRAdUnit *adUnit = nil;
    if([self.bannerInterstitialSwitch isOn]) {
        adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
    }
    else {
        adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId size:CGSizeMake(width, height)];
    }
    return @[ adUnit ];
}

- (IBAction)loadAdClick:(id)sender {

    NSString *adUnitId = self.textAdUnitId.text;
    double width = [self.textAdUnitWidth.text doubleValue];
    double height = [self.textAdUnitHeight.text doubleValue];
    CRAdUnit *adUnit = nil;
    if([self.bannerInterstitialSwitch isOn]) {
        adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
    }
    else {
        adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId size:CGSizeMake(width, height)];
    }
    DFPRequest *request = [DFPRequest request];
    //request.testDevices = @[ kGADSimulatorID ];

    /*
     Inside the cache:
     { @"/140800857/Endeavour_320x50", CGSize(320,50) } : { bid: 1.23, creative: @"test_string" }
     */

    [self.criteoSdk setBidsForRequest:request withAdUnit:adUnit];

    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:request.customTargeting];
    NSString *debugStr = [NSString stringWithFormat:@"Bid loaded in the cache at %@:\n\nCRT_CPM VALUE : %@\n\nCRT_DISPLAYURL VALUE: %@", [NSDate date], dict[@"crt_cpm"], dict[@"crt_displayUrl"]];
    [self.textFeedback setText:debugStr];

    if (dict[@"crt_displayUrl"]) {
        dict[@"crt_cpm"] = @"1.00";
        request.customTargeting = dict;
        NSLog(@"Reset @\"crt_cpm\" to @\"1.00\"");
    }

    [self debugPrintWebViewAfterSec:5];

    //Interstitial
    if([self.bannerInterstitialSwitch isOn]) {
        self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:self.textAdUnitId.text];
        [self.dfpInterstitial loadRequest:request];
        self.textFeedback.text = [self.textFeedback.text stringByAppendingString:@"\nREQUESTED INTERSTITIAL LOAD"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.dfpInterstitial.isReady) {
                [self.dfpInterstitial presentFromRootViewController:self];
            }
        });
    } else { //Banner
        [self resetDfpBannerView];
        self.dfpBannerView.adUnitID = self.textAdUnitId.text;
        [self.dfpBannerView loadRequest:request];
    }
}

- (IBAction)clearButtonClick:(id)sender {
    self.textAdUnitId.text = @"";
    self.textAdUnitWidth.text = @"";
    self.textAdUnitHeight.text = @"";
}

- (void) debugPrintWebViewAfterSec:(NSUInteger)sec
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dfpBannerView.subviews.count > 0) {
            NSLog(@"Banner view has a GADOAdView!");
            UIView *gadoAdView = self.dfpBannerView.subviews[0];

            if (gadoAdView.subviews.count > 1) {
                NSLog(@"GADOAdView has a GADOUIKitWebView!");
                UIView *gadouikitwebview = gadoAdView.subviews[1];

                if (gadouikitwebview.subviews.count > 0) {
                    NSLog(@"GADOUIKitWebView has an inner web view!");
                    UIWebView *innerWebView = (UIWebView*)gadouikitwebview.subviews[0];
                    NSString *webViewContent = [innerWebView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
                    NSLog(@"\n\nINNER WEB VIEW CONTENTS\n\n%@\n\nEND INNER WEB VIEW CONTENTS\n\n", webViewContent);
                } else {
                    NSLog(@"GADOUIKitWebView has no subviews");
                }
            } else {
                NSLog(@"GADOAdView has no subviews");
            }
        } else {
            NSLog(@"DFP Banner view has no subviews");
        }
    });
}

@end
