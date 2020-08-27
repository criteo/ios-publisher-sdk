//
//  IntegrationBaseTableViewController.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "IntegrationBaseTableViewController.h"

@implementation IntegrationBaseTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self interstitialUpdated:NO];
}

- (IBAction)interstitialSwitchChanged:(id)sender {
  [self interstitialUpdated:NO];
  UIColor *color = self.interstitialVideoSwitch.on ? UIColor.darkTextColor : UIColor.lightGrayColor;
  self.interstitialVideoSwitchLabel.textColor = color;
}

- (void)interstitialUpdated:(BOOL)loaded {
  NSString *mainButtonTitle = loaded ? @"Ad loaded" : @"Load interstitial";
  [self.loadInterstitialButton setTitle:mainButtonTitle forState:UIControlStateNormal];
  [self.interstitalSpinner stopAnimating];
  self.loadInterstitialButton.enabled = !loaded;
  self.showInterstitialButton.enabled = loaded;
}

- (void)onLoadInterstitial {
  self.loadInterstitialButton.enabled = false;
  [self.interstitalSpinner startAnimating];
}

@end
