//
//  GoogleDFPTableViewController.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CriteoPublisherSdk;
#import "IntegrationBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleDFPTableViewController : IntegrationBaseTableViewController

@property (nonatomic) IBOutlet UITextView *textFeedback;

@end

NS_ASSUME_NONNULL_END
