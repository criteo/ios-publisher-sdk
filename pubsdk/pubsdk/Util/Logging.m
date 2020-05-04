//
//  Logging.m
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "Logging.h"

void CLog_DoLog(const char *filename, int lineNum, const char *funcname, NSString * _Nonnull format, ...)
{
    NSString *fNameStr = [NSString stringWithUTF8String:filename];

    NSURL *fNameUrl = [NSURL fileURLWithPath:[fNameStr stringByExpandingTildeInPath]
                                 isDirectory:NO];

    NSString *file = fNameUrl.lastPathComponent;

    va_list pList;
    va_start(pList, format);

    NSString *annotatedFormat = [NSString stringWithFormat:@"%@:%d %s ", file, lineNum, funcname];
    annotatedFormat = [annotatedFormat stringByAppendingString:format];

    NSLogv(annotatedFormat, pList);

    va_end(pList);
}

void CLog_DoLog_Dummy(NSString * _Nonnull format, ...)
{

}
