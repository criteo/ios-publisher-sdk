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

@implementation CRMRAIDUtils
+ (NSString *)getHtmlWithMraidScriptTag {
    return [CRMRAIDUtils loadMraidFrom:@"MraidScriptTag.html"];
}

+ (NSString *)getHtmlWithDocumentWriteMraidScriptTag {
    return [CRMRAIDUtils loadMraidFrom:@"MraidDocumentTag.html"];
}

+ (NSString *)getHtmlWithoutMraidScript {
    return [CRMRAIDUtils loadMraidFrom:@"NoMraidTag.html"];
}

+ (NSString *)loadMraidFrom:(NSString *)file {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"html"];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
}

+ (NSString *)insertMraid:(NSString *)html {
    NSMutableString *mraidHtml = [NSMutableString stringWithString:html];
    NSRange bodyRange = [mraidHtml rangeOfString:@"<body>"];

    if (bodyRange.location == NSNotFound) {
        return  mraidHtml;
    }

    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CriteoMRAIDResource" ofType: @"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath: bundlePath];
    NSURL *mraidUrl = [bundle URLForResource:@"mraid" withExtension:@"ts"];
    if (mraidUrl) {
        NSInteger insertIndex = bodyRange.location + bodyRange.length;
        NSString *mraid = [NSString stringWithFormat: @"<script src=\"%@\"></script>", mraidUrl];
        [mraidHtml insertString:mraid atIndex:insertIndex];
    }

    return mraidHtml;
}

@end
