//
//  CR_NetworkSessionReader.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkSessionReader.h"
#import "CR_NetworkSessionSerializer.h"



@implementation CR_NetworkSessionReader

- (NSArray<CR_HttpContent *> *)sessionForKey:(NSString *)key {
    CR_NetworkSessionSerializer *serialized = [[CR_NetworkSessionSerializer alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:key ofType:@"json" inDirectory:@"GeneratedData"];
    if (!path) {
        return nil;
    }

    NSError *error = NULL;
    NSString *json = [[NSString alloc] initWithContentsOfFile:path
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
    NSAssert(!error, @"Failed to load the file %@: %@", path, error);
    NSArray<CR_HttpContent *> *session = [serialized sessionWithJson:json];
    return session;
}

@end
