//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "UIWebView+Testing.h"

// Remove a warning about UIWebView deprecation.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@implementation UIWebView (Testing)

- (NSString *)testing_getHtmlContent {
  NSString *script =
      @"(function() { return document.getElementsByTagName('html')[0].outerHTML; })();";
  return [self stringByEvaluatingJavaScriptFromString:script];
}

@end

#pragma GCC diagnostic pop
