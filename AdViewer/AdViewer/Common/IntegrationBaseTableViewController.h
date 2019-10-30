//
//  IntegrationBaseTableViewController.h
//  AdViewer
//
//  Created by Aleksandr Pakhmutov on 30/10/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IntegrationBaseTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *loadInterstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *showInterstitialButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitalSpinner;

- (void) updateInterstitialButtonsForAdLoaded:(BOOL)adLoaded;
- (void) onLoadInterstitial;

@end

NS_ASSUME_NONNULL_END
