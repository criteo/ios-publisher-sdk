//  Copyright 2016 LinkedIn Corporation
//  Licensed under the BSD 2-Clause License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/BSD-2-Clause
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and limitations under the License.

#import "CR_CASFileObjectQueue.h"
#import "CR_CASPrivateConstants.h"
#import "CR_CASQueueFile.h"

@interface CR_CASFileObjectQueue ()

/**
 * Backing storage implementation
 */
@property (nonatomic, nonnull, strong, readonly) CR_CASQueueFile *queueFile;

@property (nonatomic, assign) NSUInteger objectCount;

@end

@implementation CR_CASFileObjectQueue

- (instancetype)initWithRelativePath:(NSString *)filePath error:(NSError * __autoreleasing * _Nullable)error {
    NSArray<NSString *> *directoryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *absolutePath = [directoryPaths[0] stringByAppendingPathComponent:filePath];
    return [self initWithAbsolutePath:absolutePath error:error];
}

- (instancetype)initWithAbsolutePath:(NSString *)filePath error:(NSError * __autoreleasing * _Nullable)error {
    if (self = [super init]) {
        CR_CASQueueFile *queueFile = [CR_CASQueueFile queueFileWithPath:filePath error:error];
        if (error != nil && *error != nil) {
            return nil;
        }
        _queueFile = queueFile;
    }
    return self;
}

- (NSUInteger)size {
    return self.queueFile.size;
}

- (void)add:(id)data {
    NSError *error;
    NSData *serializedData;
    if (@available(iOS 11.0, macOS 10.13, *)) {
        serializedData = [NSKeyedArchiver archivedDataWithRootObject:data
                                               requiringSecureCoding:NO
                                                               error:&error];
    } else {
        serializedData = [NSKeyedArchiver archivedDataWithRootObject:data];
    }

    if (error != nil) {
        CR_CASLOG(@"error serializing data: %@", error.localizedDescription);
    } else {
        [self.queueFile add:serializedData];
    }
}

- (NSArray<id> *)peek:(NSUInteger)amount {
    NSArray<NSData *> *elements = [self.queueFile peek:amount];
    NSMutableArray<id> *coercedElements = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < elements.count; i++) {
        NSData *element = elements[i];
        id coercedElement = [self unarchiveData:element];
        if (coercedElement != nil) {
            [coercedElements addObject:coercedElement];
        }
    }
    return coercedElements;
}

- (void)pop {
    [self pop:1];
}

- (void)pop:(NSUInteger)amount {
    [self.queueFile pop:amount];
}

- (void)clear {
    [self.queueFile clear];
}

#pragma mark - Helper Method

- (nullable id)unarchiveData:(NSData *)data {
    id result;

    if (@available(iOS 11.0, macOS 10.13, *)) {
        NSError *error;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]
                                         initForReadingFromData:data
                                         error:&error];
        [unarchiver setRequiresSecureCoding:NO];
        result = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
        if (error != nil) {
            CR_CASLOG(@"error unarchiving data: %@", error.localizedDescription);
        }
    } else {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return result;
}

@end
