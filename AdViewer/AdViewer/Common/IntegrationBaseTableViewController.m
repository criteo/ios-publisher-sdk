//
//  IntegrationBaseTableViewController.m
//  AdViewer
//
//  Created by Aleksandr Pakhmutov on 30/10/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "IntegrationBaseTableViewController.h"

@interface IntegrationBaseTableViewController ()

@end

@implementation IntegrationBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateInterstitialButtonsForAdLoaded:NO];
}

- (void) updateInterstitialButtonsForAdLoaded:(BOOL)adLoaded {
    NSString* mainButtonTitle = adLoaded ? @"Ad loaded" : @"Load interstitial";
    [self.loadInterstitialButton setTitle:mainButtonTitle forState:UIControlStateNormal];
    [self.interstitalSpinner stopAnimating];
    self.loadInterstitialButton.enabled = !adLoaded;
    self.showInterstitialButton.enabled = adLoaded;
}

- (void) onLoadInterstitial {
    self.loadInterstitialButton.enabled = false;
    [self.interstitalSpinner startAnimating];
}

@end
