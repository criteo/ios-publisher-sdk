//
//  CR_NetworkManagerDecorator.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/18/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManagerDecorator.h"

#import "CR_NetworkSessionPlayer.h"
#import "CR_NetworkSessionRecorder.h"
#import "CR_NetworkCaptor.h"

@implementation CR_NetworkManagerDecorator

+ (BOOL)shouldRunTestsInIsolationFormNetwork
{
    static BOOL inInsolation = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *env = NSProcessInfo.processInfo.environment;
        inInsolation = [env[@"RUN_TESTS_IN_ISOLATION_FROM_NETWORK"] boolValue];
        NSLog(@"RUN_TESTS_IN_ISOLATION_FROM_NETWORK = %d", inInsolation);
    });
    return inInsolation;
}

+ (instancetype)decoratorFromConfiguration {
    if ([self shouldRunTestsInIsolationFormNetwork]) {
        return [[CR_NetworkManagerDecorator alloc] initWithRecordind:NO
                                                           replaying:YES
                                                           capturing:YES];
    } else {
        return [[CR_NetworkManagerDecorator alloc] initWithRecordind:YES
                                                           replaying:NO
                                                           capturing:YES];
    }
}

- (instancetype)initWithRecordind:(BOOL)recording
                        replaying:(BOOL)replaying
                        capturing:(BOOL)capturing {
    if (self = [super init]) {
        _recording = recording;
        _replaying = replaying;
        _capturing = capturing;
    }
    return self;
}

- (CR_NetworkManager *)decorateNetworkManager:(CR_NetworkManager *)networkManager {
    CR_NetworkManager *result = networkManager;
    NSString *identifier = [self _sessionIdentifier];
    if (self.isReplaying) {
        result = [[CR_NetworkSessionPlayer alloc] initWithNetworkManager:result
                                                       sessionIdentifier:identifier];
    }
    if (self.isRecording) {
        result = [[CR_NetworkSessionRecorder alloc] initWithNetworkManager:result
                                                         sessionIdentifier:identifier];
    }
    if (self.isCapturing) {
        result = [[CR_NetworkCaptor alloc] initWithNetworkManager:result];
    }
    return result;
}

- (NSString *)_sessionIdentifier
{
    NSArray<NSString *> *calls = [NSThread callStackSymbols];
    for (NSString *call in [calls reverseObjectEnumerator]) {
        if ([call containsString:@"pubsdkTests"]) {
            NSString *rightSide = [[call componentsSeparatedByString:@"["] lastObject];
            NSString *leftSide = [[rightSide componentsSeparatedByString:@"]"] firstObject];
            NSString *result = [leftSide stringByReplacingOccurrencesOfString:@" "
                                                                   withString:@"_"];
            return result;
        }
    }
    return nil;
}

@end
