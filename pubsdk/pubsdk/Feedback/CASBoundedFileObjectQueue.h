//
// Copyright (c) 2020 Criteo. All rights reserved.
//

#import "CASFileObjectQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASBoundedFileObjectQueue<T : id <NSCoding>> : CASFileObjectQueue <T>

/**
 * Initializes an @c CASBoundedFileObjectQueue with a file at the specified path,
 * with a file size boundary, returning nil if there was an error.
 * Note: Intermediate directories will not be created, create containing
 * directory before initializing.
 */
- (nullable instancetype)initWithAbsolutePath:(NSString *)filePath
                                maxFileLength:(NSUInteger)maxFileLength
                                        error:(NSError *__autoreleasing *_Nullable)error NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
