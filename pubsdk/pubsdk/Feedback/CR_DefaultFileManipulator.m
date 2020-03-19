//
//  CR_DefaultFileManipulator.m
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 26/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_DefaultFileManipulator.h"

@implementation CR_DefaultFileManipulator

- (nullable NSData *)readDataForAbsolutePath:(nonnull NSString *)path {
    return [NSData dataWithContentsOfFile:path];
}

- (void)writeData:(nonnull NSData *)data forAbsolutePath:(nonnull NSString *)path {
    NSError *error = nil;
    [data writeToFile:path
              options:NSDataWritingAtomic
                error:&error];
    NSAssert(!error, @"Impossible to write to file: %@ with error %@", path, error);
}

- (nonnull NSArray<NSURL *> *)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask {
    return [[NSFileManager defaultManager] URLsForDirectory:directory inDomains:domainMask];
}

- (nullable NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
}

- (BOOL)createDirectoryAtPath:(NSString *)path
  withIntermediateDirectories:(BOOL)createIntermediates
                   attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes
                        error:(NSError **)error {
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:error];
}

- (BOOL)fileExistsAtPath:(nonnull NSString *)path isDirectory:(nullable BOOL *)isDirectory {
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

@end
