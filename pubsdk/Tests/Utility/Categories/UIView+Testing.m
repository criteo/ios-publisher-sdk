//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "UIView+Testing.h"


@implementation UIView (Testing)

- (UIWebView *)testing_findFirstWebView {
    NSMutableArray *arr = [self testing_findAllElementsOfClass:UIWebView.class];
    return arr.count > 0 ? arr[0] : nil;
}

- (WKWebView *)testing_findFirstWKWebView {
    NSMutableArray *arr = [self testing_findAllElementsOfClass:WKWebView.class];
    return arr.count > 0 ? arr[0] : nil;
}

- (NSMutableArray*)testing_findAllElementsOfClass:(Class)class {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    [self walkOverView:self andSaveNestedElementsOfClass:class toArray:results];
    return results;
}

- (void)walkOverView:(UIView *)view andSaveNestedElementsOfClass:(Class)class toArray:(NSMutableArray *)result
{
    if([view isKindOfClass:class]) {
        [result addObject:view];
    }
    for (UIView *subview in view.subviews)
    {
        [self walkOverView:subview andSaveNestedElementsOfClass:class toArray:result];
    }
}

@end
