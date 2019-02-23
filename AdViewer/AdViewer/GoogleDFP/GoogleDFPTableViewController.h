//
//  GoogleDFPTableViewController.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

#import "NetworkManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleDFPTableViewController : UITableViewController <NetworkManagerDelegate>

@property (nonatomic) IBOutlet UITextField *textNetworkId;
@property (nonatomic) IBOutlet UITextField *textAdUnitId;
@property (nonatomic) IBOutlet UITextField *textAdUnitWidth;
@property (nonatomic) IBOutlet UITextField *textAdUnitHeight;
@property (nonatomic) IBOutlet UITextView *textFeedback;
@property (nonatomic) Criteo *criteoSdk;
@property (nonatomic) IBOutlet UISwitch *bannerInterstitialSwitch;
@property (nonatomic) IBOutlet UISwitch *gdprSwitch;


- (IBAction)loadAdClick:(id)sender;
- (IBAction)clearButtonClick:(id)sender;
- (IBAction)registerAdUnitClick:(id)sender;
- (IBAction)bannerInterstitialSwitched:(id)sender;
- (IBAction)gdprSwitched:(id)sender;

@end

NS_ASSUME_NONNULL_END
