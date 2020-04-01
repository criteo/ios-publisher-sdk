//
//  CR_UniqueIdGenerator.h
//  pubsdk
//
//  Created by Vincent Guerci on 01/04/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CR_UniqueIdGenerator : NSObject

/**
 * Generate a new unique ID suitable for Criteo backends
 * <p>
 * The output represents a 32 bytes unique ID formatted into hexadecimal. The 8 first (MSB) bytes
 * represent the UNIX timestamp in seconds. The 24 following ones are random from a cryptographic
 * random generator. This ensures keeping a very low probability of collision.
 * <p>
 * At SDK level, a simpler random [NSUUID UUID] would be sufficient. But those ids are
 * expected to be sent to a Criteo backend and should then be (almost) unique at Criteo level and
 * scale with it.
 * <p>
 * This is based on an algorithm already done in C#, Scala and Java to generate impression id.
 * <p>
 * Generation IDs are suitable for:
 * <ul>
 *   <li>Impression ID</li>
 * </ul>
 *
 * @see <a href="https://review.crto.in/gitweb?p=pub-sdk/mochi.git;a=blob;f=publisher-sdk/src/main/java/com/criteo/publisher/bid/UniqueIdGenerator.java;hb=master">
 *   Publisher SDK Android implementation</a>
 * @see <a href="https://review.crto.in/gitweb?p=publisher/direct-bidder.git;a=blob;f=directbidder-app/src/main/scala/com/criteo/directbidder/helpers/ImpressionIdHelper.scala;hb=master">
 *   CDB ImpressionIdHelper</a>
 * @see <a href="https://review.crto.in/gitweb?p=adserving-backend/criteo-arbitration.git;a=blob;f=Criteo.Arbitration.Protocol/ArbitrageId.cs;hb=master">
 *   Arbitrage ArtbitrageId</a>
 *
 * @return a new ID
 */
+ (NSString *)generateId;

+ (NSString *)generateIdWithUUID:(NSUUID *)uuid timestamp:(NSTimeInterval)timestamp;

@end

NS_ASSUME_NONNULL_END
