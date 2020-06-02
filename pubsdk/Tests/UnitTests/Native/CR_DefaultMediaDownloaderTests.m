//
//  CR_DefaultMediaDownloaderTests.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_DefaultMediaDownloader.h"
#import "CR_DependencyProvider.h"
#import "CR_ThreadManager+Waiter.h"
#import "CR_ImageCache.h"
#import "CR_NetworkManager.h"
#import "CR_DependencyProvider+Testing.h"
#import "UIImage+Testing.h"

@interface CR_DefaultMediaDownloaderTests : XCTestCase

@property(strong, nonatomic) CR_DependencyProvider *dependencyProvider;
@property(strong, nonatomic) CR_DefaultMediaDownloader *mediaDownloader;
@property(strong, nonatomic) CR_ImageCache *imageCache;
@property(strong, nonatomic) CR_NetworkManager *networkManager;

@end


@implementation CR_DefaultMediaDownloaderTests

- (void)setUp {
    self.imageCache = OCMClassMock([CR_ImageCache class]);
    self.dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
    self.dependencyProvider.imageCache = self.imageCache;

    if (self.networkManager) {
        self.dependencyProvider.networkManager = self.networkManager;
    }
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
- (void)testRetrieveImageFromCacheIfPresent {
    [self prepareMockedNetworkManager];

    NSURL *url = [[NSURL alloc] init];
    UIImage *expectedImage = [[UIImage alloc] init];

    OCMStub([self.imageCache imageForUrl:url]).andReturn(expectedImage);

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        XCTAssertEqual(image, expectedImage);
    }];

    [self waitForIdleState];

    OCMVerify(never(), [self.networkManager getFromUrl:OCMOCK_ANY
                                       responseHandler:OCMOCK_ANY]);
}

- (void)testDownloadImageAndSaveItIfNotPresentInCache {
    [self prepareMockedNetworkManager];

    NSURL *url = [[NSURL alloc] init];
    OCMStub([self.imageCache imageForUrl:url]).andReturn(nil);

    UIImage *expectedImage = [UIImage testImageNamed:@"image.jpeg"];
    NSData* downloadedData = UIImagePNGRepresentation(expectedImage);
    NSUInteger expectedSize = (NSUInteger) (expectedImage.size.width * expectedImage.size.height * 4 /* for 4 channel: RGBA */);

    OCMStub([self.networkManager getFromUrl:url
                            responseHandler:([OCMArg invokeBlockWithArgs:downloadedData, [NSNull null], nil])]);

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        XCTAssertEqualObjects(UIImagePNGRepresentation(image), downloadedData);
    }];

    [self waitForIdleState];

    OCMVerify(times(1), [self.imageCache setImage:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [downloadedData isEqualToData:UIImagePNGRepresentation(obj)];
    }]                                     forUrl:url imageSize:expectedSize]);
}

- (void)testFailToDownloadImageAndDoNotSaveItIfNotPresentInCache {
    [self prepareMockedNetworkManager];

    NSURL *url = [[NSURL alloc] init];
    OCMStub([self.imageCache imageForUrl:url]).andReturn(nil);
    OCMStub([self.networkManager getFromUrl:url responseHandler:[OCMArg invokeBlock]]);

    [self.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {}];
    [self waitForIdleState];

    OCMVerify(never(), [[(id) self.imageCache ignoringNonObjectArgs] setImage:OCMOCK_ANY forUrl:OCMOCK_ANY imageSize:0]);
}

#pragma - Private

- (void)prepareMockedNetworkManager {
    self.networkManager = OCMClassMock([CR_NetworkManager class]);
    [self setUp];
}

- (void)waitForIdleState {
    [self.dependencyProvider.threadManager waiter_waitIdle];
}


@end