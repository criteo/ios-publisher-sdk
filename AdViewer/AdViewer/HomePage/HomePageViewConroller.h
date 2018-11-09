//
//  ViewController.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/1/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageViewConroller : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonGoogleDFP;
@property (weak, nonatomic) IBOutlet UIButton *buttonMopub;

- (IBAction)buttonGoogleDFPTouchUp:(id)sender;
- (IBAction)buttonMopubTouchUp:(id)sender;


@end

