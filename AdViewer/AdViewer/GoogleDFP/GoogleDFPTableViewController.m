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

    self.textView.text = @"test";
    self.textView.text = @"";
}


# pragma mark - actions
    
- (IBAction)loadAdClick:(id)sender {
    AdViewerCdbApi *apiCaller = [[AdViewerCdbApi alloc] initWithSelector: LoadAd delegate: self];

    long profileId = [self.textPartnerId.text intValue];

    NSDictionary *profileData = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithLong: profileId], @"profileId",
        self.textImpId.text,                  @"impId",
        nil];

    NSString *message = [apiCaller loadAdWithCDB: profileData];
    if (message) {
        NSLog(@"Error: %@", message);
        return;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)clearButtonClick:(id)sender {
    self.textView.text = @"test";
    self.textView.text = @"";
}


-(void)AdViewerAPI:(AdViewerCdbApi *)api
  didFinishLoading:(NSDictionary *)response
            header:(NSDictionary *)header
           message:(NSString *)message
      selector:(enum methodSelector)selector {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (message) {
        NSLog(@"Error in CBB call: %@", message);
        self.textView.text = message;
        return;
    }

    NSError *err = nil;
    NSString *payloadString;
    NSString *headerString;

    NSData *headerData = [NSJSONSerialization dataWithJSONObject:header options:NSJSONWritingPrettyPrinted error:&err];
    if (! headerData) {
        NSLog(@"JSON Deserialization error: %@", err);
    } else {
        headerString = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding] ;
        NSLog(@"CDB Response header: %@", headerString);
    }


    if (response) {
        NSData *payloadData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&err];
        if (! payloadData) {
            NSLog(@"JSON Deserialization error: %@", err);
        } else {
            payloadString = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
            NSLog(@"CDB Response payload: %@", payloadString);
        }
    }

    self.textView.text = [NSString stringWithFormat:@"header: %@\npayload: %@@", headerString, payloadString];
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
