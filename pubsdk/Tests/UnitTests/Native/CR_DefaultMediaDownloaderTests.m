//
//  CR_DefaultMediaDownloaderTests.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_DefaultMediaDownloader.h"
#import "CR_DependencyProvider.h"
#import "CR_ThreadManager+Waiter.h"
#import "CR_DependencyProvider+Testing.h"

@interface CR_DefaultMediaDownloaderTests : XCTestCase

@property(strong, nonatomic) CR_DependencyProvider *dependencyProvider;
@property(strong, nonatomic) CR_DefaultMediaDownloader *mediaDownloader;

@end


@implementation CR_DefaultMediaDownloaderTests

- (void)setUp {
    self.dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
    self.mediaDownloader = self.dependencyProvider.mediaDownloader;
}

- (void)testDownloadingPngImage {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [testBundle URLForResource:@"image" withExtension:@"png"];

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        XCTAssertNotNil(image);
        XCTAssertNil(error);
    }];

    [self waitForIdleState];
}

- (void)testDownloadingJpgImage {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [testBundle URLForResource:@"image" withExtension:@"jpeg"];

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        XCTAssertNotNil(image);
        XCTAssertNil(error);
    }];

    [self waitForIdleState];
}

- (void)testDownloadingUnknownImage {
    NSURL *url = [NSURL URLWithString:@"file://an.image.url.that.does.not/exist"];

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        XCTAssertNil(image);
        XCTAssertNotNil(error);
    }];

    [self waitForIdleState];
}

#pragma - Private

- (void)waitForIdleState {
    [self.dependencyProvider.threadManager waiter_waitIdle];
}

@end