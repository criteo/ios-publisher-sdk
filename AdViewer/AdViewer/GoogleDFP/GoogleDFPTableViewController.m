//
//  GoogleDFPTableViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "GoogleDFPTableViewController.h"

@interface GoogleDFPTableViewController ()

@end

@implementation GoogleDFPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


# pragma mark - actions
    
- (IBAction)LoadAdClick:(id)sender {
    AdViewerCdbApi *apiCaller = [[AdViewerCdbApi alloc] initWithSelector: LoadAd delegate: self];
    NSDictionary *profileData =
    [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithLong: 217], @"profileId",  // Add more keys and values to the dictionary to pass parameters to api caller
        @"1139617", @"impId",
        nil];

    NSString *message = [apiCaller LoadAd: profileData];
    if (message) {
        NSLog(@"Error: %@", message);
        return;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


-(void)AdViewerAPI:(AdViewerCdbApi *)api didFinishLoading:(NSDictionary *)response message:(NSString *)message
      selector:(enum methodSelector)selector {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (message) {
        NSLog(@"Error: %@", message);
        return;
    }

}

    
#pragma mark - Table view data source

   
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


@end
