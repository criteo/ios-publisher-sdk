//
//  CRMediaContent.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"

@implementation CRMediaContent

- (instancetype)initWithImageUrl:(NSURL *)imageUrl {
    if (self = [super init]) {
        _imageUrl = imageUrl;
    }
    return self;
}

@end