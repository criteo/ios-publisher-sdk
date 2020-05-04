//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CASBoundedFileObjectQueue.h"
#import "CASQueueFile.h"

/**
 * Expose the CASFileObjectQueue private queueFile.fileLength property
 * Starts with QueueFileInitialLength = 4096 then grows by *2 as needed
*/
@interface CASFileObjectQueue (private)
@property (nonatomic, nonnull, strong, readonly) CASQueueFile *queueFile;
@end

@interface CASQueueFile (private)
@property (nonatomic, readwrite) NSUInteger fileLength;
@end

@interface CASBoundedFileObjectQueue ()
@property (assign, nonatomic, readonly) NSUInteger maxFileLength;
@end

@implementation CASBoundedFileObjectQueue

- (instancetype)initWithAbsolutePath:(NSString *)filePath
                       maxFileLength:(NSUInteger)maxFileLength
                               error:(NSError *__autoreleasing *_Nullable)error {
    if (self = [super initWithAbsolutePath:filePath error:error]) {
        _maxFileLength = maxFileLength;
    }
    return self;
}

- (void)add:(id <NSCoding>)data {
    [super add:data];
    if (self.queueFile.fileLength > self.maxFileLength) {
        [self pop];
    }
}

@end
