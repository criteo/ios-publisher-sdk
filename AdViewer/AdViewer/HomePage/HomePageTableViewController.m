//
//  ViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/1/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <MoPub.h>
#import "Logs.h"
#import "HomePageTableViewController.h"
#import "MopubTableViewController.h"
#import "GoogleDFPTableViewController.h"
#import "StandaloneTableViewController.h"

NSString * const HomePageTableViewControllerUsPrivacyIabConsentStringKey = @"IABUSPrivacy_String";

@interface HomePageTableViewController () <NetworkManagerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) MoPub *mopub;
@property (strong, nonatomic) Criteo *criteo;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) LogManager *logManager;

@property (weak, nonatomic) IBOutlet UISwitch *gdprSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *criteoCcpaSwitch;
@property (weak, nonatomic) IBOutlet UITextField *iabCcpaTextField;
@property (weak, nonatomic) IBOutlet UITextField *mopubTextField;
@property (weak, nonatomic) GoogleDFPTableViewController *googleDfpVC;
@property (weak, nonatomic) MopubTableViewController *moPubVC;
@property (weak, nonatomic) StandaloneTableViewController *standaloneVC;

@end

@implementation HomePageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.criteo = [Criteo sharedCriteo];
    self.mopub = [MoPub sharedInstance];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.logManager = [LogManager sharedInstance];
    [self clearUserDefaults];
    [self _setupCriteoCcpaSwitch];
    [self _setupIabCcpaTextField];
    [self setGdpr:YES];

    self.googleBannerAdUnit_320x50 = [[CRBannerAdUnit alloc] initWithAdUnitId:GOOGLEBANNERADUNITID_320x50 size:CGSizeMake(320, 50)];
    self.googleBannerAdUnit_300x250 = [[CRBannerAdUnit alloc] initWithAdUnitId:GOOGLEBANNERADUNITID_300X250 size:CGSizeMake(300, 250)];
    self.googleNativeAdUnit_Fluid = [[CRNativeAdUnit alloc] initWithAdUnitId:GOOGLENATIVEADUNITID_FLUID];
    self.googleInterstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:GOOGLEINTERSTITIALADUNITID];

    self.moPubBannerAdUnit_320x50 = [[CRBannerAdUnit alloc] initWithAdUnitId:MOPUBBANNERADUNITID_320X50 size:CGSizeMake(320, 50)];
    self.moPubBannerAdUnit_300x250 = [[CRBannerAdUnit alloc] initWithAdUnitId:MOPUBBANNERADUNITID_300X250 size:CGSizeMake(300, 250)];
    self.moPubInterstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:MOPUBINTERSTITIALADUNITID];

    self.criteoBannerAdUnit_320x50 = [[CRBannerAdUnit alloc] initWithAdUnitId:CRITEOBANNERADUNITID_320x50 size:CGSizeMake(320, 50)];
    self.criteoInterstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId: CRITEOINTERSTITIALID];
    self.criteoInterstitialVideoAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId: CRITEOVIDEOADUNITID];
    self.criteoNativeAdUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:CRITEONATIVEADUNITID];
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
                                     self.criteoInterstitialAdUnit,
                                     self.criteoInterstitialVideoAdUnit,
                                     self.criteoNativeAdUnit];

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
    [self.logManager log:[[RequestLogEntry alloc] initWithRequest:request]];
    [self setAvailableTextFeedback];
    NSString *body = nil;

    if (request.HTTPBody) {
        body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    }

    self.textFeedback.text = [self.textFeedback.text stringByAppendingFormat:@"\n\n\nREQ:\n%@ %@\nHeaders: %@\nBody: %@\n\n\n",
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
    [self.logManager log:[[ResponseLogEntry alloc] initWithResponse:response data:data error:error]];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

    if (error)
    {
        self.textFeedback.text = [self.textFeedback.text stringByAppendingFormat:@"\n\n\n\n\nRESP:\nError: %@\nReason: %@\n\n\n",
                              error.localizedDescription,
                              error.localizedFailureReason];

        if (httpResponse) {
            self.textFeedback.text = [self.textFeedback.text stringByAppendingFormat:@"\n\n\n\nStatus: %ld %@\n\n\n",
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

#pragma mark - CCPA

- (void)_setupIabCcpaTextField {
    NSAssert(self.iabCcpaTextField, @"iabCcpaTextField not assigned");
    self.iabCcpaTextField.delegate = self;
    self.iabCcpaTextField.text = [self _iabCcpaString];
}

- (void)_setupCriteoCcpaSwitch {
    NSAssert(self.criteoCcpaSwitch, @"criteoCcpaSwitch not assigned");
    [self.criteo setUsPrivacyOptOut:NO];
    self.criteoCcpaSwitch.on = NO;
}

- (IBAction)onCriteoCCPASwitch:(id)sender {
    [self.criteo setUsPrivacyOptOut:self.criteoCcpaSwitch.on];
}

- (IBAction)onCCPAIabChange:(UITextField *)textField {
    [self.userDefaults setObject:textField.text
                          forKey:HomePageTableViewControllerUsPrivacyIabConsentStringKey];
}

- (NSString *)_iabCcpaString {
    return [self.userDefaults objectForKey:HomePageTableViewControllerUsPrivacyIabConsentStringKey];
}

#pragma mark - Mopub

- (IBAction)onMopubConsentChange:(UITextField *)textField {
    [self.criteo setMopubConsent:textField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
