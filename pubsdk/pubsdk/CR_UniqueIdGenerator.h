//
//  CR_UniqueIdGenerator.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
 * @see Publisher SDK Android implementation:
 *https://review.crto.in/gitweb?p=pub-sdk/mochi.git;a=blob;f=publisher-sdk/src/main/java/com/criteo/publisher/bid/UniqueIdGenerator.java;hb=master
 * @see CDB ImpressionIdHelper
 * https://review.crto.in/gitweb?p=publisher/direct-bidder.git;a=blob;f=directbidder-app/src/main/scala/com/criteo/directbidder/helpers/ImpressionIdHelper.scala;hb=master
 * @see Arbitrage ArtbitrageId:
 * https://review.crto.in/gitweb?p=adserving-backend/criteo-arbitration.git;a=blob;f=Criteo.Arbitration.Protocol/ArbitrageId.cs;hb=master
 *
 * @return a new ID
 */
+ (NSString *)generateId;

+ (NSString *)generateIdWithUUID:(NSUUID *)uuid timestamp:(NSTimeInterval)timestamp;

@end

NS_ASSUME_NONNULL_END
