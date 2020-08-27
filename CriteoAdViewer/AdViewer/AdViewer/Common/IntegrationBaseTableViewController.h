//
//  IntegrationBaseTableViewController.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageTableViewController.h"
#import "InterstitialUpdateDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface IntegrationBaseTableViewController : UITableViewController <InterstitialUpdateDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loadInterstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *showInterstitialButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitalSpinner;
@property (weak, nonatomic) IBOutlet UISwitch *interstitialVideoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *interstitialVideoSwitchLabel;

@property (nonatomic, strong) HomePageTableViewController *homePageVC;

- (void)onLoadInterstitial;

@end

NS_ASSUME_NONNULL_END
