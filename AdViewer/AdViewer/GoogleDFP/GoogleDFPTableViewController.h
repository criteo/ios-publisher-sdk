//
//  GoogleDFPTableViewController.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pubsdk/pubsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleDFPTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *textNetworkId;
@property (weak, nonatomic) IBOutlet UITextField *textAdUnitId;
@property (weak, nonatomic) IBOutlet UITextField *textAdUnitWidth;
@property (weak, nonatomic) IBOutlet UITextField *textAdUnitHeight;
@property (weak, nonatomic) IBOutlet UITextView *textFeedback;
@property (nonatomic) Criteo *criteoSdk;


- (IBAction)loadAdClick:(id)sender;
- (IBAction)clearButtonClick:(id)sender;
- (IBAction)registerAdUnitClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
