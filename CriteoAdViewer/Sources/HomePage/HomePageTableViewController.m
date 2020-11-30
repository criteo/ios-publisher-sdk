//
//  HomePageTableViewController.m
//  CriteoAdViewer
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

#import <MoPub.h>
#import "LogManager.h"
#import "HomePageTableViewController.h"
#import "MopubTableViewController.h"
#import "GoogleDFPTableViewController.h"
#import "StandaloneTableViewController.h"
#import "CRVNativeAdViewController.h"

NSString *const HomePageTableViewControllerUsPrivacyIabConsentStringKey = @"IABUSPrivacy_String";

@interface HomePageTableViewController () <UITextFieldDelegate, CRVNativeAdViewControllerDelegate>

@property(strong, nonatomic) MoPub *mopub;
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property(strong, nonatomic) LogManager *logManager;

@property(weak, nonatomic) IBOutlet UISwitch *gdprSwitch;
@property(weak, nonatomic) IBOutlet UISwitch *criteoCcpaSwitch;
@property(weak, nonatomic) IBOutlet UITextField *iabCcpaTextField;
@property(weak, nonatomic) IBOutlet UITextField *mopubTextField;
@property(weak, nonatomic) GoogleDFPTableViewController *googleDfpVC;
@property(weak, nonatomic) MopubTableViewController *moPubVC;
@property(weak, nonatomic) StandaloneTableViewController *standaloneVC;

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

  self.googleBannerAdUnit_320x50 =
      [[CRBannerAdUnit alloc] initWithAdUnitId:GOOGLEBANNERADUNITID_320x50
                                          size:CGSizeMake(320, 50)];
  self.googleBannerAdUnit_300x250 =
      [[CRBannerAdUnit alloc] initWithAdUnitId:GOOGLEBANNERADUNITID_300X250
                                          size:CGSizeMake(300, 250)];
  self.googleNativeAdUnit_Fluid =
      [[CRNativeAdUnit alloc] initWithAdUnitId:GOOGLENATIVEADUNITID_FLUID];
  self.googleInterstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:GOOGLEINTERSTITIALADUNITID];

  self.moPubBannerAdUnit_320x50 =
      [[CRBannerAdUnit alloc] initWithAdUnitId:MOPUBBANNERADUNITID_320X50 size:CGSizeMake(320, 50)];
  self.moPubBannerAdUnit_300x250 =
      [[CRBannerAdUnit alloc] initWithAdUnitId:MOPUBBANNERADUNITID_300X250
                                          size:CGSizeMake(300, 250)];
  self.moPubInterstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:MOPUBINTERSTITIALADUNITID];

  self.criteoBannerAdUnit_320x50 =
      [[CRBannerAdUnit alloc] initWithAdUnitId:CRITEOBANNERADUNITID_320x50
                                          size:CGSizeMake(320, 50)];
  self.criteoInterstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:CRITEOINTERSTITIALID];
  self.criteoInterstitialVideoAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:CRITEOVIDEOADUNITID];
  self.criteoNativeAdUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:CRITEONATIVEADUNITID];
}
- (IBAction)registerCriteo:(id)sender {
  Criteo *criteo = [Criteo sharedCriteo];

  NSArray<CRAdUnit *> *addUnits = @[
    self.googleBannerAdUnit_320x50, self.googleBannerAdUnit_300x250, self.moPubBannerAdUnit_320x50,
    self.moPubBannerAdUnit_300x250, self.googleInterstitialAdUnit, self.moPubInterstitialAdUnit,
    self.googleNativeAdUnit_Fluid, self.criteoBannerAdUnit_320x50, self.criteoInterstitialAdUnit,
    self.criteoInterstitialVideoAdUnit, self.criteoNativeAdUnit
  ];

  [criteo registerCriteoPublisherId:@"B-056946" withAdUnits:addUnits];

  criteo.networkManagerDelegate = self.logManager;
  UIButton *button = (UIButton *)sender;
  [button setEnabled:NO];

  [criteo setUserData:[CRUserData userDataWithDictionary:@{
            CRUserDataHashedEmail : [CREmailHasher hash:@"john.doe@gmail.com"],
            CRUserDataDevUserId : @"devUserId"
          }]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.destinationViewController isKindOfClass:[MopubTableViewController class]]) {
    self.moPubVC = (MopubTableViewController *)segue.destinationViewController;
    self.moPubVC.homePageVC = self;
  } else if ([segue.destinationViewController isKindOfClass:[GoogleDFPTableViewController class]]) {
    self.googleDfpVC = (GoogleDFPTableViewController *)segue.destinationViewController;
    self.googleDfpVC.homePageVC = self;
  } else if ([segue.destinationViewController
                 isKindOfClass:[StandaloneTableViewController class]]) {
    self.standaloneVC = (StandaloneTableViewController *)segue.destinationViewController;
    self.standaloneVC.homePageVC = self;
  } else if ([segue.destinationViewController isKindOfClass:[CRVNativeAdViewController class]]) {
    [(CRVNativeAdViewController *)segue.destinationViewController setDelegate:self];
  }
}

#pragma mark - GDPR
- (IBAction)gdprSwitchAction:(id)sender {
  if ([self.gdprSwitch isOn]) {
    [self setGdpr:YES];
  } else {
    [self clearUserDefaults];
  }
}

- (void)setGdpr:(BOOL)applies {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setValue:@(applies) forKey:@"IABConsent_SubjectToGDPR"];
  if (applies) {
    [userDefaults
        setValue:
            @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA"
          forKey:@"IABConsent_ConsentString"];
    // Criteo is at 91
    [userDefaults
        setValue:
            @"0000000000000010000000000000000000000100000000000000000000000000000000000000000000000000001"
          forKey:@"IABConsent_ParsedVendorConsents"];
  } else {
    [userDefaults removeObjectForKey:@"IABConsent_ConsentString"];
    [userDefaults removeObjectForKey:@"IABConsent_ParsedVendorConsents"];
  }
}

- (void)clearUserDefaults {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults removeObjectForKey:@"IABConsent_SubjectToGDPR"];
  [userDefaults removeObjectForKey:@"IABConsent_ConsentString"];
  [userDefaults removeObjectForKey:@"IABConsent_ParsedVendorConsents"];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self clearUserDefaults];
  [super viewDidDisappear:animated];
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

#pragma mark - CRVNativeAdViewController

- (CRNativeAdUnit *)adUnitForViewController:(CRVNativeAdViewController *)viewController {
  return self.criteoNativeAdUnit;
}

@end
