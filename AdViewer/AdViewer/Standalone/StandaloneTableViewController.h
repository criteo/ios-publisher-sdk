//
//  StandaloneViewControllerTableViewController.h
//  AdViewer
//
//  Created by Aleksandr Pakhmutov on 29/10/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageTableViewController.h"
#import "IntegrationBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface StandaloneTableViewController : IntegrationBaseTableViewController

@property (nonatomic, strong) HomePageTableViewController *homePageVC;

@end

NS_ASSUME_NONNULL_END
