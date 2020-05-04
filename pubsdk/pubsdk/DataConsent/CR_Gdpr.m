//
//  CR_Gdpr.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_Gdpr.h"
#import "CR_GdprVersion.h"

@interface CR_Gdpr ()

@property (strong, nonatomic, readonly) id<CR_GdprVersion> noGdpr;
@property (copy, nonatomic, readonly) NSArray<id<CR_GdprVersion>> *sorteredVersions;
@property (strong, nonatomic, readonly) id<CR_GdprVersion> selectedVersion;

@end

@implementation CR_Gdpr

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    if (self = [super init]) {
        _noGdpr = [[CR_NoGdpr alloc] init];
        _sorteredVersions = @[
            [CR_GdprVersionWithKeys gdprTcf2_0WithUserDefaults:userDefaults],
            [CR_GdprVersionWithKeys gdprTcf1_1WithUserDefaults:userDefaults]
        ];
    }
    return self;
}

#pragma mark - Custom Accessors

- (CR_GdprTcfVersion)tcfVersion {
    return self.selectedVersion.tcfVersion;
}

- (NSString *)consentString {
    return self.selectedVersion.consentString;
}

- (NSNumber *)applies {
    return self.selectedVersion.applies;
}

#pragma mark - Private

- (id<CR_GdprVersion>)selectedVersion {
    for (id<CR_GdprVersion> version in self.sorteredVersions) {
        if (version.isValid) {
            return version;
        }
    }
    return self.noGdpr;
}


#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<%@: %p, tcfVersion: %ld, isApplied: %@, consentString: %@>",
            NSStringFromClass(self.class),
            self,
            (long)self.tcfVersion,
            self.applies,
            self.consentString
            ];
}

@end
