//
//  ViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/1/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "HomePageTableViewController.h"
#import "MopubTableViewController.h"
#import "GoogleDFPTableViewController.h"
#import "StandaloneTableViewController.h"


@interface HomePageTableViewController () <NetworkManagerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *gdprSwitch;
@property (weak, nonatomic) GoogleDFPTableViewController *googleDfpVC;
@property (weak, nonatomic) MopubTableViewController *moPubVC;
@property (weak, nonatomic) StandaloneTableViewController *standaloneVC;

@end

@implementation HomePageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self clearUserDefaults];
    [self setGdpr:YES];
    self.googleInterstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:GOOGLEINTERSTITIALADUNITID];
    self.moPubInterstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:MOPUBINTERSTITIALADUNITID];
    self.googleBannerAdUnit_320x50 = [[CRBannerAdUnit alloc] initWithAdUnitId:GOOGLEBANNERADUNITID_320x50 size:CGSizeMake(320, 50)];
    self.googleBannerAdUnit_300x250 = [[CRBannerAdUnit alloc] initWithAdUnitId:GOOGLEBANNERADUNITID_300X250 size:CGSizeMake(300, 250)];
    self.moPubBannerAdUnit_320x50 = [[CRBannerAdUnit alloc] initWithAdUnitId:MOPUBBANNERADUNITID_320X50 size:CGSizeMake(320, 50)];
    self.moPubBannerAdUnit_300x250 = [[CRBannerAdUnit alloc] initWithAdUnitId:MOPUBBANNERADUNITID_300X250 size:CGSizeMake(300, 250)];
    self.googleNativeAdUnit_Fluid = [[CRNativeAdUnit alloc] initWithAdUnitId:GOOGLENATIVEADUNITID_FLUID];

    self.criteoBannerAdUnit_320x50 = [[CRBannerAdUnit alloc]
                                      initWithAdUnitId:CRITEOBANNERADUNITID_320x50
                                      size:CGSizeMake(320, 50)];

    self.criteoInterstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId: CRITEOINTERSTITIALID];
}
- (IBAction)registerCriteo:(id)sender {
    Criteo *criteo = [Criteo sharedCriteo];

    NSArray<CRAdUnit*> *addUnits = @[self.googleBannerAdUnit_320x50,
                                     self.googleBannerAdUnit_300x250,
                                     self.moPubBannerAdUnit_320x50,
                                     self.moPubBannerAdUnit_300x250,
                                     self.googleInterstitialAdUnit,
                                     self.moPubInterstitialAdUnit,
                                     self.googleNativeAdUnit_Fluid,
                                     self.criteoBannerAdUnit_320x50,
                                     self.criteoInterstitialAdUnit];

    [criteo registerCriteoPublisherId:@"B-056946" withAdUnits:addUnits];

    criteo.networkMangerDelegate = self;
    UIButton *button = (UIButton *)sender;
    [button setEnabled:NO];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:[MopubTableViewController class]]) {
        self.moPubVC = (MopubTableViewController *)segue.destinationViewController;
        self.moPubVC.homePageVC = self;
    }
    else if([segue.destinationViewController isKindOfClass:[GoogleDFPTableViewController class]]) {
        self.googleDfpVC = (GoogleDFPTableViewController *)segue.destinationViewController;
        self.googleDfpVC.homePageVC = self;
    }
    else if([segue.destinationViewController isKindOfClass:[StandaloneTableViewController class]]) {
        self.standaloneVC = (StandaloneTableViewController *)segue.destinationViewController;
        self.standaloneVC.homePageVC = self;
    }
}

#pragma mark - GDPR
- (IBAction)gdprSwitchAction:(id)sender {
    if([self.gdprSwitch isOn]) {
        [self setGdpr:YES];
    }
    else {
        [self clearUserDefaults];
    }
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

- (void) viewDidDisappear:(BOOL)animated {
    [self clearUserDefaults];
}

- (void)setAvailableTextFeedback {
    if(self.googleDfpVC) {
        _textFeedback = self.googleDfpVC.textFeedback;
    }
    else if(self.moPubVC) {
        _textFeedback = self.moPubVC.textFeedBack;
    }
}

// Criteo NetworkManagerDelegate Implementation
- (void) networkManager:(NetworkManager*)manager sentRequest:(NSURLRequest*)request
{
    [self setAvailableTextFeedback];
    self.textFeedback.text = @"";

    NSString *body = nil;

    if (request.HTTPBody) {
        body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    }

    self.textFeedback.text = [self.textFeedback.text stringByAppendingFormat:@"REQ:\n%@ %@\nHeaders: %@\nBody: %@",
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
        self.textFeedback.text = [self.textFeedback.text stringByAppendingFormat:@"\n\nRESP:\nError: %@\nReason: %@",
                              error.localizedDescription,
                              error.localizedFailureReason];

        if (httpResponse) {
            self.textFeedback.text = [self.textFeedback.text stringByAppendingFormat:@"\nStatus: %ld %@",
                                  (long)httpResponse.statusCode,
                                  [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
        }

        return;
    }

    NSString *body = nil;

    if (data) {
        body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    self.textFeedback.text = [self.textFeedback.text stringByAppendingFormat:@"\n\nRESP:\nStatus: %ld %@\nBody: %@",
                          (long)httpResponse.statusCode,
                          [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode],
                          body];
}


@end
