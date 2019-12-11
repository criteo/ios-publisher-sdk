//
// Created by Aleksandr Pakhmutov on 09/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (Testing)

- (UIWebView *)testing_findFirstWebView;
- (NSMutableArray<UIWebView *>*)testing_findAllWebView;

@end