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
#import "CR_CASDefaultDataSerializer.h"

@interface CR_CASFileObjectQueue ()

/**
 * Backing storage implementation
 */
@property (nonatomic, nonnull, strong, readonly) CR_CASQueueFile *queueFile;

@property (nonatomic, nonnull, strong, readonly) id<CR_CASDataSerializer> serializer;

@property (nonatomic, assign) NSUInteger objectCount;

@end

@implementation CR_CASFileObjectQueue

- (instancetype)initWithRelativePath:(NSString *)filePath error:(NSError * __autoreleasing * _Nullable)error {
    return [self initWithRelativePath:filePath serializer:[CR_CASDefaultDataSerializer shared] error:error];
}

- (instancetype)initWithRelativePath:(NSString *)filePath serializer:(id<CR_CASDataSerializer>)serializer error:(NSError *__autoreleasing  _Nullable *)error {
    NSArray<NSString *> *directoryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *absolutePath = [directoryPaths[0] stringByAppendingPathComponent:filePath];
    return [self initWithAbsolutePath:absolutePath serializer:serializer error:error];
}

- (instancetype)initWithAbsolutePath:(NSString *)filePath error:(NSError * __autoreleasing * _Nullable)error {
    return [self initWithAbsolutePath:filePath serializer:[CR_CASDefaultDataSerializer shared] error:error];
}

- (instancetype)initWithAbsolutePath:(NSString *)filePath serializer:(id<CR_CASDataSerializer>)serializer error:(NSError *__autoreleasing  _Nullable *)error {
    if (self = [super init]) {
        CR_CASQueueFile *queueFile = [CR_CASQueueFile queueFileWithPath:filePath error:error];
        if (error != nil && *error != nil) {
            return nil;
        }
        _queueFile = queueFile;
        _serializer = serializer;
    }
    return self;
}

- (NSUInteger)size {
    return self.queueFile.size;
}

- (BOOL)add:(id)data error:(NSError * __autoreleasing * _Nullable)error {
    NSData *serializedData = [self.serializer serialize:data error:error];

    if (!serializedData) {
        if (error) {
            CR_CASLOG(@"Error serializing data: %@", *error);
        }
        return NO;
    } else {
        return [self.queueFile add:serializedData error:error];
    }
}

- (NSArray<id> * _Nullable)peek:(NSUInteger)amount error:(NSError * __autoreleasing * _Nullable)error {
    NSArray<NSData *> *elements = [self.queueFile peek:amount error:error];
    if (!elements) {
        if (error) {
            CR_CASLOG(@"Error peeking %zu items: %@", amount, *error);
        }
        return nil;
    }
    NSMutableArray<id> *coercedElements = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < elements.count; i++) {
        NSData *element = elements[i];
        id coercedElement = [self deserialize:element error:error];
        if (coercedElement != nil) {
            [coercedElements addObject:coercedElement];
        } else {
            if (error) {
                CR_CASLOG(@"Error deserializing element %zu: %@", i, *error);
            }
            return nil;
        }
    }
    return coercedElements;
}

- (BOOL)pop:(NSUInteger)amount error:(NSError * __autoreleasing * _Nullable)error {
    return [self.queueFile pop:amount error:error];
}

- (BOOL)clearAndReturnError:(NSError * __autoreleasing * _Nullable)error {
    return [self.queueFile clearAndReturnError:error];
}

#pragma mark - Helper Method

- (nullable id)deserialize:(NSData *)data error:(NSError * __autoreleasing * _Nullable)error {
    id result = [self.serializer deserialize:data error:error];
    if (!result && error) {
        CR_CASLOG(@"Error deserializing data: %@", *error);
    }

    return result;
}

@end
