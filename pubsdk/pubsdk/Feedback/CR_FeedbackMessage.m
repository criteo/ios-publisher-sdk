//
//  CR_FeedbackMessage.m
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 19/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_FeedbackMessage.h"

@implementation CR_FeedbackMessage

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.impressionId forKey:@"impressionId"];
    [coder encodeObject:self.requestGroupId forKey:@"requestGroupId"];
    [coder encodeObject:self.cdbCallStartTimestamp forKey:@"cdbCallStartTimestamp"];
    [coder encodeObject:self.cdbCallEndTimestamp forKey:@"cdbCallEndTimestamp"];
    [coder encodeObject:self.elapsedTimestamp forKey:@"elapsedTimestamp"];
    [coder encodeBool:self.timeout forKey:@"timeout"];
    [coder encodeBool:self.expired forKey:@"expired"];
    [coder encodeBool:self.cachedBidUsed forKey:@"cachedBidUsed"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.impressionId = [coder decodeObjectOfClass:NSString.class forKey:@"impressionId"];
        self.requestGroupId = [coder decodeObjectOfClass:NSString.class forKey:@"requestGroupId"];
        self.cdbCallStartTimestamp = [coder decodeObjectOfClass:NSNumber.class forKey:@"cdbCallStartTimestamp"];
        self.cdbCallEndTimestamp = [coder decodeObjectOfClass:NSNumber.class forKey:@"cdbCallEndTimestamp"];
        self.elapsedTimestamp = [coder decodeObjectOfClass:NSNumber.class forKey:@"elapsedTimestamp"];
        self.timeout = [coder decodeBoolForKey:@"timeout"];
        self.expired = [coder decodeBoolForKey:@"expired"];
        self.cachedBidUsed = [coder decodeBoolForKey:@"cachedBidUsed"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{\n\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@}",
                                      [NSString stringWithFormat:@"impressionId: %@\n", self.impressionId],
                                      [NSString stringWithFormat:@"requestGroupId: %@\n", self.requestGroupId],
                                      [NSString stringWithFormat:@"cdbCallStartTimestamp: %@\n", self.cdbCallStartTimestamp],
                                      [NSString stringWithFormat:@"cdbCallEndTimestamp: %@\n", self.cdbCallEndTimestamp],
                                      [NSString stringWithFormat:@"elapsedTimestamp: %@\n", self.elapsedTimestamp],
                                      [NSString stringWithFormat:@"timeout: %@\n", @(self.timeout)],
                                      [NSString stringWithFormat:@"expired: %@\n", @(self.expired)],
                                      [NSString stringWithFormat:@"cachedBidUsed: %@\n", @(self.cachedBidUsed)]
    ];
}

- (BOOL)isReadyToSend {
    return self.elapsedTimestamp != nil || self.expired || self.timeout;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equality methods

- (BOOL)isEqualToFeedbackMessage:(CR_FeedbackMessage *)other {
    BOOL impIdEq = (!self.impressionId && !other.impressionId) ||
        (self.impressionId && other.impressionId &&
         [self.impressionId isEqualToString:other.impressionId]);

    BOOL grpIdEq = (!self.requestGroupId && !other.requestGroupId) ||
        (self.requestGroupId && other.requestGroupId &&
         [self.requestGroupId isEqualToString:other.requestGroupId]);

    BOOL cdbStEq = (!self.cdbCallStartTimestamp && !other.cdbCallStartTimestamp) ||
        (self.cdbCallStartTimestamp && other.cdbCallStartTimestamp &&
         [self.cdbCallStartTimestamp isEqualToNumber:other.cdbCallStartTimestamp]);

    BOOL cdbEndEq = (!self.cdbCallEndTimestamp && !other.cdbCallEndTimestamp) ||
        (self.cdbCallEndTimestamp && other.cdbCallEndTimestamp &&
         [self.cdbCallEndTimestamp isEqualToNumber:other.cdbCallEndTimestamp]);

    BOOL elpTimeEq = (!self.elapsedTimestamp && !other.elapsedTimestamp) ||
        (self.elapsedTimestamp && other.elapsedTimestamp &&
         [self.elapsedTimestamp isEqualToNumber:other.elapsedTimestamp]);

    return impIdEq && grpIdEq && cdbStEq && cdbEndEq && elpTimeEq &&
        self.timeout == other.timeout &&
        self.expired == other.expired &&
        self.cachedBidUsed == other.cachedBidUsed;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[CR_FeedbackMessage class]]) {
        return NO;
    }

    return [self isEqualToFeedbackMessage:object];
}

- (NSUInteger)hash {
    NSUInteger timeoutHash = [@(self.timeout) unsignedIntegerValue];
    NSUInteger expiredHash = [@(self.expired) unsignedIntegerValue];
    NSUInteger cachedBidUsed = [@(self.cachedBidUsed) unsignedIntegerValue];
    return [self.impressionId hash] << 1 ^
        [self.requestGroupId hash] << 2 ^
        [self.cdbCallStartTimestamp hash] << 3 ^
        [self.cdbCallEndTimestamp hash] << 4 ^
        [self.elapsedTimestamp hash] << 5 ^
        expiredHash << 6 ^
        timeoutHash << 7 ^
        cachedBidUsed << 8;
}

@end
