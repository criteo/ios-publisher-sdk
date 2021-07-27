//  Copyright 2021 LinkedIn Corporation
//  Licensed under the BSD 2-Clause License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://opensource.org/licenses/BSD-2-Clause
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and limitations under the License.

#import "CR_CASDefaultDataSerializer.h"
#import "CR_CASPrivateConstants.h"

@implementation CR_CASDefaultDataSerializer

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[CR_CASDefaultDataSerializer alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}

- (id _Nullable)deserialize:(nonnull NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (@available(iOS 11.0, macOS 10.13, *)) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:error];
        [unarchiver setRequiresSecureCoding:NO];
        return [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    } else {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

- (NSData * _Nullable)serialize:(nonnull id)object error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (@available(iOS 11.0, macOS 10.13, *)) {
        return [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:error];
    } else {
        return [NSKeyedArchiver archivedDataWithRootObject:object];
    }
}

@end
