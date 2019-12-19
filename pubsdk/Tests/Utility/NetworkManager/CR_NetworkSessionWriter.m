//
//  CR_NetworkCache.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/17/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_NetworkSessionWriter.h"
#import "CR_NetworkSessionSerializer.h"
#import "CR_Assert.h"

@interface CR_NetworkSessionWriter ()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *fileDirectory;
@property (nonatomic, strong) CR_NetworkSessionSerializer *serializer;

@end

@implementation CR_NetworkSessionWriter

+ (void)initialize {
    // https://developer.apple.com/documentation/objectivec/nsobject/1418639-initialize?language=objc
    NSString *tmpDir = NSTemporaryDirectory();
    NSLog(@"%@ will flush in the following directory: %@", NSStringFromClass([self class]), tmpDir);
}

+ (instancetype)defaultNetworkSessionCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *fileDir = [[NSString alloc] initWithFormat:@"%@sessions", tmpDir];

    if(![fileManager fileExistsAtPath:fileDir isDirectory:NULL]) {
        NSError *error = NULL;
        [fileManager createDirectoryAtPath:fileDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        NSAssert(!error, @"Impossible to create directory %@: %@", fileDir, error);
    }
    BOOL create = [fileManager isWritableFileAtPath:fileDir];
    CR_Assert(create, @"Cannot create file: %@", fileDir);

    return [[CR_NetworkSessionWriter alloc] initWithWithFileManager:fileManager
                                                     fileDirectory:fileDir];
}

- (instancetype)initWithWithFileManager:(NSFileManager *)fileManager
                          fileDirectory:(NSString *)fileDirectory {
    if (self = [super init])
    {
        _fileManager = fileManager;
        _fileDirectory = fileDirectory;
        _serializer = [[CR_NetworkSessionSerializer alloc] init];
    }
    return self;
}

- (void)setSession:(NSArray<CR_HttpContent *> *)contents
            forKey:(NSString *)key {
    NSString *json = [self.serializer jsonWithSession:contents];
    NSString *filePath = [self _pathForKey:key];
    NSError *error = NULL;
    [json writeToFile:filePath
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:&error];
    NSAssert(!error, @"Error while writing in the file %@: %@", filePath, error);
}

- (NSString *)_pathForKey:(NSString *)key {
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@.json", key];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@", self.fileDirectory, fileName];
    return filePath;
}

@end
