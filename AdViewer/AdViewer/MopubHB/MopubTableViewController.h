//
//  MopubViewController.h
//  AdViewer
//
//  Created by Sneha Pathrose on 9/13/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MoPub.h>
#import "IntegrationBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MopubTableViewController : IntegrationBaseTableViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textFeedBack;

@end

NS_ASSUME_NONNULL_END
