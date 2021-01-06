//
//  CR_DefaultFileManipulator.m
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

#import "CR_DefaultFileManipulator.h"

@implementation CR_DefaultFileManipulator

- (nullable NSData *)readDataForAbsolutePath:(nonnull NSString *)path {
  return [NSData dataWithContentsOfFile:path];
}

- (void)writeData:(nonnull NSData *)data forAbsolutePath:(nonnull NSString *)path {
  NSError *error = nil;
  [data writeToFile:path options:NSDataWritingAtomic error:&error];
  NSAssert(!error, @"Impossible to write to file: %@ with error %@", path, error);
}

- (nonnull NSArray<NSURL *> *)URLsForDirectory:(NSSearchPathDirectory)directory
                                     inDomains:(NSSearchPathDomainMask)domainMask {
  return [[NSFileManager defaultManager] URLsForDirectory:directory inDomains:domainMask];
}

- (NSString *)libraryPath {
  return [self URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].firstObject.path;
}

- (nullable NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path
                                                      error:(NSError **)error {
  return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:error];
}

- (NSUInteger)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
  NSArray<NSString *> *files = [self contentsOfDirectoryAtPath:path error:error];
  NSUInteger size = 0;
  for (NSString *file in files) {
    NSString *filePath = [path stringByAppendingPathComponent:file];
    NSDictionary<NSFileAttributeKey, id> *attributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:error];
    size += [attributes fileSize];
  }
  return size;
}

- (BOOL)createDirectoryAtPath:(NSString *)path
    withIntermediateDirectories:(BOOL)createIntermediates
                     attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes
                          error:(NSError **)error {
  return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:createIntermediates
                                                    attributes:attributes
                                                         error:error];
}

- (BOOL)fileExistsAtPath:(nonnull NSString *)path isDirectory:(nullable BOOL *)isDirectory {
  return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
  return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

@end
