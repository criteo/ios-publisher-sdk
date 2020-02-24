//
//  CR_FeedbackFileManager.m
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 24/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_FeedbackFileManager.h"

@interface CR_FeedbackFileManager ()

@property(strong, nonatomic, readonly) NSString *activeMetricsPath;
@property(strong, nonatomic, readonly) id <CR_FileManipulating> fileManipulating;

@end

@implementation CR_FeedbackFileManager

- (instancetype)initWithFileManipulating:(id <CR_FileManipulating>)fileManipulating {
    if (self = [super init]) {
        _fileManipulating = fileManipulating;

        NSArray<NSURL *> *directoryUrls = [fileManipulating URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
        if (directoryUrls.count == 0) {
            return nil;
        }

        NSString *rootDirectoryPath = [directoryUrls[0] path];
        NSString *metricsRootPath = [rootDirectoryPath stringByAppendingString:@"/criteo_metrics"];
        _activeMetricsPath = [metricsRootPath stringByAppendingString:@"/active"];
        _sendingQueueFilePath = [metricsRootPath stringByAppendingString:@"/sendingQueue"];

        if (![fileManipulating fileExistsAtPath:_activeMetricsPath isDirectory:nil]) {
            [fileManipulating createDirectoryAtPath:_activeMetricsPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (nullable CR_FeedbackMessage *)readFeedbackForFilename:(NSString *)filename {
    NSData *content = [self.fileManipulating readDataForAbsolutePath:[self buildAbsolutePathByFilename:filename]];
    if (@available(iOS 11.0, *)) {
        return [NSKeyedUnarchiver unarchivedObjectOfClass:CR_FeedbackMessage.class fromData:content error:nil];
    } else {
        return [NSKeyedUnarchiver unarchiveObjectWithData:content];
    }
}

- (void)writeFeedback:(CR_FeedbackMessage *)feedback forFilename:(NSString *)filename {
    NSData *content = nil;
    if (@available(iOS 11.0, *)) {
        content = [NSKeyedArchiver archivedDataWithRootObject:feedback requiringSecureCoding:NO error:nil];
    } else {
        content = [NSKeyedArchiver archivedDataWithRootObject:feedback];
    }

    [self.fileManipulating writeData:content forAbsolutePath:[self buildAbsolutePathByFilename:filename]];
}

- (void)removeFileForFilename:(NSString *)filename {
    [self.fileManipulating removeItemAtPath:[self buildAbsolutePathByFilename:filename] error:nil];
}

- (NSArray<NSString *> *)allActiveFeedbackFilenames {
    return [self.fileManipulating contentsOfDirectoryAtPath:[self activeMetricsPath] error:nil];
}

#pragma mark - Private methods

- (NSString *)buildAbsolutePathByFilename:(NSString *)filename {
    return [self.activeMetricsPath stringByAppendingFormat:@"/%@", filename];
}

@end


@implementation CR_DefaultFileManipulating

- (nullable NSData *)readDataForAbsolutePath:(nonnull NSString *)path {
    return [NSData dataWithContentsOfFile:path];
}

- (void)writeData:(nonnull NSData *)data forAbsolutePath:(nonnull NSString *)path {
    [data writeToFile:path atomically:YES];
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
