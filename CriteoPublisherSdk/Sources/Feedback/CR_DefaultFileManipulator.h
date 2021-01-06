//
//  CR_DefaultFileManipulator.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CR_FileManipulating <NSObject>

@required

- (void)writeData:(NSData *)data forAbsolutePath:(NSString *)path;

- (nullable NSData *)readDataForAbsolutePath:(NSString *)path;

- (NSArray<NSURL *> *)URLsForDirectory:(NSSearchPathDirectory)directory
                             inDomains:(NSSearchPathDomainMask)domainMask;
@property(nonatomic, readonly, nullable) NSString *libraryPath;

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(nullable BOOL *)isDirectory;

- (BOOL)createDirectoryAtPath:(NSString *)path
    withIntermediateDirectories:(BOOL)createIntermediates
                     attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes
                          error:(NSError **)error;

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

- (nullable NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path
                                                      error:(NSError **)error;

- (NSUInteger)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

@end

@interface CR_DefaultFileManipulator : NSObject <CR_FileManipulating>

@end

NS_ASSUME_NONNULL_END
