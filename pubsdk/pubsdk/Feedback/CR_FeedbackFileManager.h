//
//  CR_FeedbackFileManager.h
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 24/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_FeedbackMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CR_FileManipulating;

@interface CR_FeedbackFileManager : NSObject

@property(strong, nonatomic) NSString *sendingQueueFilePath;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFileManipulating:(NSObject <CR_FileManipulating> *)fileManipulating NS_DESIGNATED_INITIALIZER;

- (nullable CR_FeedbackMessage *)readFeedbackForFilename:(NSString *)filename;

- (void)writeFeedback:(CR_FeedbackMessage *)feedback forFilename:(NSString *)filename;

- (void)removeFileForFilename:(NSString *)filename;

- (NSArray<NSString *> *)allActiveFeedbackFilenames;

@end


@protocol CR_FileManipulating <NSObject>

@required

- (void)writeData:(NSData *)data forAbsolutePath:(NSString *)path;

- (nullable NSData *)readDataForAbsolutePath:(NSString *)path;

- (NSArray<NSURL *> *)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask;

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(nullable BOOL *)isDirectory;

- (BOOL)createDirectoryAtPath:(NSString *)path
  withIntermediateDirectories:(BOOL)createIntermediates
                   attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes
                        error:(NSError **)error;

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

- (nullable NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

@end


@interface CR_DefaultFileManipulating : NSObject <CR_FileManipulating>

@end

NS_ASSUME_NONNULL_END
