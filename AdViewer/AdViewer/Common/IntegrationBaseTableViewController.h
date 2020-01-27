//
//  IntegrationBaseTableViewController.h
//  AdViewer
//
//  Created by Aleksandr Pakhmutov on 30/10/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface IntegrationBaseTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *loadInterstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *showInterstitialButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitalSpinner;
@property (weak, nonatomic) IBOutlet UISwitch *interstitialVideoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *interstitialVideoSwitchLabel;

@property (nonatomic, strong) HomePageTableViewController *homePageVC;

- (void) updateInterstitialButtonsForAdLoaded:(BOOL)adLoaded;
- (void) onLoadInterstitial;
- (CRInterstitialAdUnit *) adUnitForInterstitial;

@end

NS_ASSUME_NONNULL_END
