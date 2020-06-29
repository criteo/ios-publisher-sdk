//
//  CR_ImageCacheTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_ImageCache.h"

@interface CR_ImageCacheTests : XCTestCase
@end

@implementation CR_ImageCacheTests

- (void)testImageForUrlReturnsNilGivenCacheIsEmpty {
  NSURL *url = [[NSURL alloc] initWithString:@"1"];
  CR_ImageCache *cache = [[CR_ImageCache alloc] initWithSizeLimit:10];

  UIImage *image = [cache imageForUrl:url];

  XCTAssertNil(image);
}

- (void)testImageForUrlReturnsLastSavedImageGivenSameUrl {
  NSURL *url1 = [[NSURL alloc] initWithString:@"1"];
  NSURL *url2 = [[NSURL alloc] initWithString:@"2"];

  UIImage *oldSavedImage1 = [[UIImage alloc] init];
  UIImage *savedImage1 = [[UIImage alloc] init];
  UIImage *savedImage2 = [[UIImage alloc] init];

  CR_ImageCache *cache = [[CR_ImageCache alloc] initWithSizeLimit:10];

  [cache setImage:oldSavedImage1 forUrl:url1 imageSize:1];
  [cache setImage:savedImage1 forUrl:url1 imageSize:1];
  [cache setImage:savedImage2 forUrl:url2 imageSize:1];
  UIImage *image1 = [cache imageForUrl:url1];
  UIImage *image2 = [cache imageForUrl:url2];

  XCTAssertEqual(image1, savedImage1);
  XCTAssertEqual(image2, savedImage2);
}

- (void)testImageForUrlReturnsNilGivenDifferentUrl {
  NSURL *url1 = [[NSURL alloc] initWithString:@"1"];
  NSURL *url2 = [[NSURL alloc] initWithString:@"2"];
  UIImage *savedImage = [[UIImage alloc] init];

  CR_ImageCache *cache = [[CR_ImageCache alloc] initWithSizeLimit:10];

  [cache setImage:savedImage forUrl:url1 imageSize:1];
  UIImage *image = [cache imageForUrl:url2];

  XCTAssertNil(image);
}

- (void)testImageForUrlReturnsNilGivenSavedImageOverAllocatedCapacity {
  NSURL *url = [[NSURL alloc] initWithString:@"1"];
  UIImage *savedImage = [[UIImage alloc] init];

  CR_ImageCache *cache = [[CR_ImageCache alloc] initWithSizeLimit:2];

  [cache setImage:savedImage forUrl:url imageSize:3];
  UIImage *image = [cache imageForUrl:url];

  XCTAssertNil(image);
}

- (void)testEvictionFollowsLruPolicyGivenDifferentSize {
  NSURL *url1 = [[NSURL alloc] initWithString:@"1"];
  NSURL *url2 = [[NSURL alloc] initWithString:@"2"];
  NSURL *url3 = [[NSURL alloc] initWithString:@"3"];
  NSURL *url4 = [[NSURL alloc] initWithString:@"4"];
  NSURL *url5 = [[NSURL alloc] initWithString:@"5"];

  UIImage *savedImage1 = [[UIImage alloc] init];
  UIImage *savedImage2 = [[UIImage alloc] init];
  UIImage *savedImage3 = [[UIImage alloc] init];
  UIImage *savedImage4 = [[UIImage alloc] init];
  UIImage *savedImage5 = [[UIImage alloc] init];

  CR_ImageCache *cache = [[CR_ImageCache alloc] initWithSizeLimit:10];

  [cache setImage:savedImage1 forUrl:url1 imageSize:3];  // Capa: 3/10
  [cache setImage:savedImage2 forUrl:url2 imageSize:3];  // Capa: 6/10
  [cache setImage:savedImage3 forUrl:url3 imageSize:3];  // Capa: 9/10
  [cache setImage:savedImage1 forUrl:url1 imageSize:4];  // Capa: 10/10, image1 is LRU
  [cache setImage:savedImage4 forUrl:url4 imageSize:4];  // Capa: 8/10, image2 and image3 are out
  [cache imageForUrl:url2];                              // no effect
  [cache imageForUrl:url1];                              // Capa: 8/10, image1 is LRU
  [cache setImage:savedImage5 forUrl:url5 imageSize:3];  // Capa: 7/10, image4 is out

  UIImage *image1 = [cache imageForUrl:url1];
  UIImage *image2 = [cache imageForUrl:url2];
  UIImage *image3 = [cache imageForUrl:url3];
  UIImage *image4 = [cache imageForUrl:url4];
  UIImage *image5 = [cache imageForUrl:url5];

  XCTAssertEqual(image1, savedImage1);
  XCTAssertNil(image2);
  XCTAssertNil(image3);
  XCTAssertNil(image4);
  XCTAssertEqual(image5, savedImage5);
}

- (void)testEvictionFollowsLruPolicyGivenLotOfImages {
  NSURL *keptUrl = [[NSURL alloc] initWithString:@"kept"];
  UIImage *keptImage = [[UIImage alloc] init];
  NSMutableArray<NSURL *> *evictedUrls = [[NSMutableArray alloc] init];

  CR_ImageCache *cache = [[CR_ImageCache alloc] initWithSizeLimit:10];

  for (int i = 0; i < 20; ++i) {
    UIImage *image = [[UIImage alloc] init];
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%d", i]];
    [evictedUrls addObject:url];
    [cache setImage:image forUrl:url imageSize:1];
  }

  [cache setImage:keptImage forUrl:keptUrl imageSize:10];

  for (int i = 0; i < evictedUrls.count; ++i) {
    NSURL *url = evictedUrls[(NSUInteger)i];
    XCTAssertNil([cache imageForUrl:url]);
  }

  XCTAssertEqual([cache imageForUrl:keptUrl], keptImage);
}

@end