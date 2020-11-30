//
//  CREmailHasher.m
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

#import "CREmailHasher.h"
#include <CommonCrypto/CommonDigest.h>

@implementation CREmailHasher

+ (NSString *)hash:(NSString *)email {
  NSString *trimmed = [email stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  NSString *lowered = trimmed.lowercaseString;
  NSData *data = [lowered dataUsingEncoding:NSUTF8StringEncoding];

  NSMutableData *md5Data = [NSMutableData dataWithLength:CC_MD5_DIGEST_LENGTH];
  CC_MD5(data.bytes, (CC_LONG)data.length, md5Data.mutableBytes);
  NSString *md5HexRepresentation = [CREmailHasher hexRepresentation:md5Data];
  NSData *md5HexData = [md5HexRepresentation dataUsingEncoding:NSASCIIStringEncoding];

  NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(md5HexData.bytes, (CC_LONG)md5HexData.length, sha256Data.mutableBytes);

  return [CREmailHasher hexRepresentation:sha256Data];
}

+ (NSString *)hexRepresentation:(NSData *)data {
  NSMutableString *hexRepresentation = [NSMutableString stringWithCapacity:data.length * 2];
  unsigned char buffer[data.length];
  [data getBytes:buffer length:data.length];
  for (int i = 0; i < data.length; i++) {
    [hexRepresentation appendFormat:@"%02x", buffer[i]];
  }
  return hexRepresentation;
}

@end