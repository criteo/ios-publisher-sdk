//
//  CRMediaViewTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "NSInvocation+OCMAdditions.h"
#import "CRMediaView.h"
#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"
#import "CRMediaDownloader.h"
#import "NSURL+Criteo.h"
#import "UIImage+Testing.h"

@interface CRMediaViewTests : XCTestCase
@end

@implementation CRMediaViewTests

- (void)testSetMediaContent_GivenNoPlaceholderAndFailingLoader_SetNothingInView {
    NSURL *url = [[NSURL alloc] initWithString:@"http://image.url"];
    CRMediaView *mediaView = [self buildMediaView];
    CRMediaContent *mediaContent = [self buildMediaContent:url.absoluteString];

    [self prepareFailingLoaderIn:mediaContent andExpectedUrl:url];

    mediaView.mediaContent = mediaContent;

    XCTAssertEqual(1, mediaView.subviews.count);
    XCTAssertNil([self getImageInMediaView:mediaView]);
}

- (void)testSetMediaContent_GivenPlaceholderAndNoUrl_SetPlaceholderInView {
    CRMediaView *mediaView = [self buildMediaView];
    CRMediaContent *mediaContent = [self buildMediaContent:nil];
    UIImage *placeholder = [self imageWithWidth:1];

    mediaView.placeholder = placeholder;
    mediaView.mediaContent = mediaContent;

    XCTAssertEqual(1, mediaView.subviews.count);
    XCTAssertEqual(placeholder, [self getImageInMediaView:mediaView]);
}

- (void)testSetMediaContent_GivenPlaceholderAndFailingLoader_SetPlaceholderInView {
    NSURL *url = [[NSURL alloc] initWithString:@"http://image.url"];
    CRMediaView *mediaView = [self buildMediaView];
    CRMediaContent *mediaContent = [self buildMediaContent:url.absoluteString];
    UIImage *placeholder = [self imageWithWidth:1];

    [self prepareFailingLoaderIn:mediaContent andExpectedUrl:url];

    mediaView.placeholder = placeholder;
    mediaView.mediaContent = mediaContent;

    XCTAssertEqual(1, mediaView.subviews.count);
    XCTAssertEqual(placeholder, [self getImageInMediaView:mediaView]);
}

- (void)testSetMediaContent_GivenPlaceholderAndSuccessfulLoader_SetPlaceholderThenDownloadedImageInView {
    NSURL *url = [[NSURL alloc] initWithString:@"http://image.url"];
    CRMediaView *mediaView = [self buildMediaView];
    CRMediaContent *mediaContent = [self buildMediaContent:url.absoluteString];
    UIImage *placeholder = [self imageWithWidth:1];
    UIImage *downloadedImage = [self imageWithWidth:2];

    [self prepareSuccessfulLoaderIn:mediaContent
                     andExpectedUrl:url
                 andDownloadedImage:downloadedImage
             andExpectedPlaceholder:placeholder
                        inMediaView:mediaView];

    mediaView.placeholder = placeholder;
    mediaView.mediaContent = mediaContent;

    XCTAssertEqual(1, mediaView.subviews.count);
    XCTAssertEqual(downloadedImage, [self getImageInMediaView:mediaView]);
}

- (void)testSetMediaContent_GivenPlaceholderAndMultipleSuccessfulCall_SetPlaceholderOncePerUrl {
    NSURL *url1 = [[NSURL alloc] initWithString:@"http://image.url/1"];
    NSURL *url2 = [[NSURL alloc] initWithString:@"http://image.url/2"];
    CRMediaView *mediaView = [self buildMediaView];
    CRMediaContent *mediaContent1 = [self buildMediaContent:url1.absoluteString];
    CRMediaContent *mediaContent2 = [self buildMediaContent:url1.absoluteString];
    CRMediaContent *mediaContent3 = [self buildMediaContent:url2.absoluteString];
    UIImage *downloadedImage1 = [self imageWithWidth:1];
    UIImage *downloadedImage2 = [self imageWithWidth:2];
    UIImage *downloadedImage3 = [self imageWithWidth:3];
    UIImage *downloadedImage4 = [self imageWithWidth:4];
    UIImage *placeholder = [self imageWithWidth:5];

    [self prepareSuccessfulLoaderIn:mediaContent1
                     andExpectedUrl:url1
                 andDownloadedImage:downloadedImage1
             andExpectedPlaceholder:placeholder
                        inMediaView:mediaView];

    [self prepareSuccessfulLoaderIn:mediaContent1
                     andExpectedUrl:url1
                 andDownloadedImage:downloadedImage2
             andExpectedPlaceholder:downloadedImage1
                        inMediaView:mediaView];

    [self prepareSuccessfulLoaderIn:mediaContent2
                     andExpectedUrl:url1
                 andDownloadedImage:downloadedImage3
             andExpectedPlaceholder:downloadedImage2
                        inMediaView:mediaView];

    [self prepareSuccessfulLoaderIn:mediaContent3
                     andExpectedUrl:url2
                 andDownloadedImage:downloadedImage4
             andExpectedPlaceholder:placeholder
                        inMediaView:mediaView];

    mediaView.placeholder = placeholder;
    mediaView.mediaContent = mediaContent1;
    mediaView.mediaContent = mediaContent1;
    mediaView.mediaContent = mediaContent2;
    mediaView.mediaContent = mediaContent3;

    XCTAssertEqual(1, mediaView.subviews.count);
    XCTAssertEqual(downloadedImage4, [self getImageInMediaView:mediaView]);
}

#pragma mark - Private

- (UIImage *)imageWithWidth:(CGFloat)width {
    return [UIImage imageWithSize:(CGSize) {width, 0}];
}

- (CRMediaView *)buildMediaView {
    return [[CRMediaView alloc] initWithFrame:(CGRect) {0, 0, 42, 1337}];
}

- (CRMediaContent *)buildMediaContent:(NSString *)url {
    id mockDownloader = OCMStrictProtocolMock(@protocol(CRMediaDownloader));
    NSURL *imageUrl = [NSURL cr_URLWithStringOrNil:url];
    return [[CRMediaContent alloc] initWithUrl:imageUrl
                               mediaDownloader:mockDownloader];
}

- (UIImage *)getImageInMediaView:(CRMediaView *)mediaView {
    return ((UIImageView *) mediaView.subviews.firstObject).image;
}

- (void)prepareFailingLoaderIn:(CRMediaContent *)mediaContent
                andExpectedUrl:(NSURL *)url {
    OCMExpect([mediaContent.mediaDownloader downloadImage:url completionHandler:OCMOCK_ANY])
            .andDo(^(NSInvocation *args) {
                CRImageDownloaderHandler completionHandler = [args getArgumentAtIndexAsObject:3];
                completionHandler(nil, [[NSError alloc] init]);
            });
}

- (void)prepareSuccessfulLoaderIn:(CRMediaContent *)mediaContent
                   andExpectedUrl:(NSURL *)url
               andDownloadedImage:(UIImage *)downloadedImage
           andExpectedPlaceholder:(UIImage *)placeholder
                      inMediaView:(CRMediaView *)mediaView {
    OCMExpect([mediaContent.mediaDownloader downloadImage:url completionHandler:OCMOCK_ANY])
            .andDo(^(NSInvocation *args) {
                if (placeholder != [self getImageInMediaView:mediaView]) {
                    NSLog(@"Stack trace : %@",[NSThread callStackSymbols]);
                }
                XCTAssertEqual(placeholder, [self getImageInMediaView:mediaView]);
                CRImageDownloaderHandler completionHandler = [args getArgumentAtIndexAsObject:3];
                completionHandler(downloadedImage, nil);
            });
}

@end