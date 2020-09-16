//
//  IntegrationBaseTableViewController.m
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
