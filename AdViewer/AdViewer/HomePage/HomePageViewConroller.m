//
//  ViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/1/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "HomePageViewConroller.h"

@interface HomePageViewConroller ()

@end

@implementation HomePageViewConroller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)buttonGoogleDFPTouchUp:(id)sender {
    NSLog(@"Hello button!");
    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"GoogleDFP"];
    [self.navigationController pushViewController:vc animated:YES];*/
    
}

- (IBAction)buttonMopubTouchUp:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"Mopub"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
