//
//  CR_DefaultFileManipulator.h
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 26/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

- (NSUInteger)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

@end


@interface CR_DefaultFileManipulator : NSObject <CR_FileManipulating>

@end

NS_ASSUME_NONNULL_END
