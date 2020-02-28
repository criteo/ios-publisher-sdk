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
    [coder encodeObject:self.cdbCallStartTimestamp forKey:@"cdbCallStartTimestamp"];
    [coder encodeObject:self.cdbCallEndTimestamp forKey:@"cdbCallEndTimestamp"];
    [coder encodeObject:self.elapsedTimestamp forKey:@"elapsedTimestamp"];
    [coder encodeBool:self.timeouted forKey:@"isTimeouted"];
    [coder encodeBool:self.expired forKey:@"isExpired"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.impressionId = [coder decodeObjectOfClass:NSString.class forKey:@"impressionId"];
        self.cdbCallStartTimestamp = [coder decodeObjectOfClass:NSNumber.class forKey:@"cdbCallStartTimestamp"];
        self.cdbCallEndTimestamp = [coder decodeObjectOfClass:NSNumber.class forKey:@"cdbCallEndTimestamp"];
        self.elapsedTimestamp = [coder decodeObjectOfClass:NSNumber.class forKey:@"elapsedTimestamp"];
        self.timeouted = [coder decodeBoolForKey:@"isTimeouted"];
        self.expired = [coder decodeBoolForKey:@"isExpired"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{\n\t%@\t%@\t%@\t%@\t%@\t%@}",
                                      [NSString stringWithFormat:@"impressionId: %@\n", self.impressionId],
                                      [NSString stringWithFormat:@"cdbCallStartTimestamp: %@\n", self.cdbCallStartTimestamp],
                                      [NSString stringWithFormat:@"cdbCallEndTimestamp: %@\n", self.cdbCallEndTimestamp],
                                      [NSString stringWithFormat:@"elapsedTimestamp: %@\n", self.elapsedTimestamp],
                                      [NSString stringWithFormat:@"isTimeouted: %@\n", @(self.timeouted)],
                                      [NSString stringWithFormat:@"isExpired: %@\n", @(self.expired)]
    ];
}

- (BOOL)isReadyToSend {
    return self.elapsedTimestamp != nil || self.expired || self.timeouted;
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

    BOOL cdbStEq = (!self.cdbCallStartTimestamp && !other.cdbCallStartTimestamp) ||
        (self.cdbCallStartTimestamp && other.cdbCallStartTimestamp &&
         [self.cdbCallStartTimestamp isEqualToNumber:other.cdbCallStartTimestamp]);

    BOOL cdbEndEq = (!self.cdbCallEndTimestamp && !other.cdbCallEndTimestamp) ||
        (self.cdbCallEndTimestamp && other.cdbCallEndTimestamp &&
         [self.cdbCallEndTimestamp isEqualToNumber:other.cdbCallEndTimestamp]);

    BOOL elpTimeEq = (!self.elapsedTimestamp && !other.elapsedTimestamp) ||
        (self.elapsedTimestamp && other.elapsedTimestamp &&
         [self.elapsedTimestamp isEqualToNumber:other.elapsedTimestamp]);

    return impIdEq && cdbStEq && cdbEndEq && elpTimeEq &&
        self.timeouted == other.timeouted &&
        self.expired == other.expired;
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
    NSUInteger timeoutedHash = [@(self.timeouted) unsignedIntegerValue];
    NSUInteger expiredHash = [@(self.expired) unsignedIntegerValue];
    return [self.impressionId hash] << 1 ^
        [self.cdbCallStartTimestamp hash] << 2 ^
        [self.cdbCallEndTimestamp hash] << 3 ^
        [self.elapsedTimestamp hash] << 4 ^
        expiredHash << 5 ^
        timeoutedHash << 6;
}

@end
