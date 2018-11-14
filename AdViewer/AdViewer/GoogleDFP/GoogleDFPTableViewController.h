//
//  GoogleDFPTableViewController.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdViewerCdbApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleDFPTableViewController : UITableViewController
<AdViewerCdbApiDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textPartnerId;
@property (weak, nonatomic) IBOutlet UITextField *textImpId;
@property (weak, nonatomic) IBOutlet UITextView *textView;


- (IBAction)loadAdClick:(id)sender;
- (IBAction)clearButtonClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
