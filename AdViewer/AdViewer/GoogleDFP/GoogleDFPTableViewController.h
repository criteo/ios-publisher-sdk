//
//  GoogleDFPTableViewController.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CriteoPublisherSdk;
#import "HomePageTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleDFPTableViewController : UITableViewController

@property (nonatomic, strong) HomePageTableViewController *homePageVC;
@property (nonatomic) IBOutlet UITextView *textFeedback;

@end

NS_ASSUME_NONNULL_END
