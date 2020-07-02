//
//  CR_UniqueIdGenerator.m
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

#import "CR_UniqueIdGenerator.h"

@implementation CR_UniqueIdGenerator

+ (NSString *)generateId {
  NSUUID *uuid = [NSUUID UUID];
  NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
  return [self generateIdWithUUID:uuid timestamp:timestamp];
}

+ (NSString *)generateIdWithUUID:(NSUUID *)uuid timestamp:(NSTimeInterval)timestamp {
  uuid_t data;  // unsigned char * 16 = 128 bits
  [uuid getUUIDBytes:data];
  u_int64_t msb = 0, lsb = 0;
  for (int i = 0; i < 8; i++) {
    msb = (msb << 8) | (data[i] & 0xff);
  }
  for (int i = 8; i < 16; i++) {
    lsb = (lsb << 8) | (data[i] & 0xff);
  }

  // Move 1st byte at 13th position. And 2nd one at 17th (which is the 1st of LSB)
  // 13th and 17th digits are not random in UUID spec, so we put random ones instead.
  msb = [self setByteAt:msb byteIndex:12 byteToSet:[self getByteAt:msb byteIndex:0]];
  lsb = [self setByteAt:lsb byteIndex:0 byteToSet:[self getByteAt:msb byteIndex:1]];

  // Paste in the timestamp at the 8 MSB
  u_int64_t timeInSecond = (u_int64_t)timestamp;
  msb = (timeInSecond << 32) | (msb & 0xFFFFFFFFL);

  // Note that the %x formatter only support 32 bits, %016x does not work
  // @see
  // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
  return [NSString stringWithFormat:@"%08x%08x%08x%08x", (int32_t)(msb >> 32), (int32_t)msb,
                                    (int32_t)(lsb >> 32), (int32_t)lsb];
}

/**
 * Return the byte in the given value at the given index.
 * <p>
 * The index is from left to right, so the 1st one represent the MSB byte of the value and the
 * 15th represent the LSB byte.
 *
 * @param value     value to read the byte from
 * @param byteIndex index from left to right of the byte to read
 * @return byte at given index
 */
+ (u_int8_t)getByteAt:(u_int64_t)value byteIndex:(u_int8_t)byteIndex {
  int32_t index = 64 - ((byteIndex + 1) << 2);
  u_int64_t byteToGetMask = ((u_int64_t)0xF) << index;
  return (u_int8_t)((value & byteToGetMask) >> index & 0xF);
}

/**
 * Set the given byte in the given value at given index.
 * <p>
 * The index is from left to right, so the 1st one represent the MSB byte of the value and the
 * 15th represent the LSB byte.
 *
 * @param value     value to set byte in
 * @param byteIndex index (from left to right) where to set the byte
 * @param byteToSet byte to inject at given index
 * @return value with the byte set
 */
+ (u_int64_t)setByteAt:(u_int64_t)value byteIndex:(int)byteIndex byteToSet:(char)byteToSet {
  int32_t index = 64 - ((byteIndex + 1) << 2);
  u_int64_t byteToSetMask = ((u_int64_t)0xF) << index;
  u_int64_t valueWithoutDestination = value & ~byteToSetMask;
  u_int64_t byteToCopyAtDestination = ((u_int64_t)byteToSet) << index;
  return valueWithoutDestination | byteToCopyAtDestination;
}

@end
