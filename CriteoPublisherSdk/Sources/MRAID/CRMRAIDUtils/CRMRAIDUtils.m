//
//  CRMRAIDUtils.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CRMRAIDUtils.h"
#import "CRMRAIDConstants.h"

@implementation CRMRAIDUtils

#pragma mark - mraid script injection
+ (NSString *)loadMraidFromBundle:(NSBundle *)bundle {
    NSURL *mraidUrl = [bundle URLForResource:CR_MRAID_FILE_NAME withExtension:CR_MRAID_FILE_EXTENSION];
    NSError *error;
    NSString *mraid = [NSString stringWithContentsOfURL:mraidUrl
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];
    if (error) {
        return NULL;
    }
    return mraid;
}

+ (NSString *)insertMraid:(NSString *)html fromBundle:(NSBundle *)bundle {
  NSMutableString *mraidHtml = [NSMutableString stringWithString:html];
  NSRange bodyRange = [mraidHtml rangeOfString:CR_MRAID_INJECT_TARGET];

  if (bodyRange.location == NSNotFound) {
      return mraidHtml;
  }

  NSString *mraidContent = [CRMRAIDUtils loadMraidFromBundle:bundle];
    
  if (mraidContent) {
    NSInteger insertIndex = bodyRange.location + bodyRange.length;
    NSString *mraid = [NSString stringWithFormat:CR_MRAID_SCRIPT, mraidContent];
    [mraidHtml insertString:mraid atIndex:insertIndex];
  }

  return mraidHtml;
}

+ (NSBundle *)mraidResourceBundle {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:CR_MRAID_BUNDLE
                                                                    ofType:CR_MRAID_BUNDLE_EXTENSION]];
}

@end
