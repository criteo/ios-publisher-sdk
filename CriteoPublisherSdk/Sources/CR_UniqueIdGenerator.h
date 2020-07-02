//
//  CR_UniqueIdGenerator.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CR_UniqueIdGenerator : NSObject

/**
 * Generate a new unique ID suitable for Criteo backends
 *
 * The output represents a 32 bytes unique ID formatted into hexadecimal. The 8
 * first (MSB) bytes represent the UNIX timestamp in seconds. The 24 following
 * ones are random from a cryptographic random generator. This ensures keeping a
 * very low probability of collision. At SDK level, a simpler random [NSUUID
 * UUID] would be sufficient. But those ids are expected to be sent to a Criteo
 * backend and should then be (almost) unique at Criteo level and scale with it.
 *
 * This is based on an algorithm already done in C#, Scala and Java to generate
 * impression id. Generation IDs are suitable for Impression IDs
 *
 * @see Publisher SDK Android version has a similar implementation
 * @see CDB ImpressionIdHelper: https://go.crto.in/publisher-sdk-cdb-impressionidhelper
 * @see Arbitrage ArtbitrageId: https://go.crto.in/publisher-sdk-arbitrage-arbitrageid
 *
 * @return a new ID
 */
+ (NSString *)generateId;

+ (NSString *)generateIdWithUUID:(NSUUID *)uuid timestamp:(NSTimeInterval)timestamp;

@end

NS_ASSUME_NONNULL_END
