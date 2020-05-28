//
//  CR_DefaultMediaDownloaderTests.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_DefaultMediaDownloader.h"
#import "XCTestCase+Criteo.h"

@interface CR_DefaultMediaDownloaderTests : XCTestCase

@property (strong, nonatomic) CR_DefaultMediaDownloader *mediaDownloader;

@end


@implementation CR_DefaultMediaDownloaderTests

- (void)setUp {
    self.mediaDownloader = [[CR_DefaultMediaDownloader alloc] init];
}

- (void)testDownloadingPngImage {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [testBundle URLForResource:@"image" withExtension:@"png"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"image is loaded"];

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        XCTAssertNotNil(image);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self cr_waitForExpectations:@[expectation]];
}

- (void)testDownloadingJpgImage {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [testBundle URLForResource:@"image" withExtension:@"jpeg"];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"image is loaded"];

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        XCTAssertNotNil(image);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self cr_waitForExpectations:@[expectation]];
}

@end