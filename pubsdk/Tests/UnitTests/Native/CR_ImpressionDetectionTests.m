//
//  CR_ImpressionDetectionTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_ImpressionDetector.h"

@interface CR_ImpressionDetectionTests : XCTestCase

@property (strong, nonatomic) UIWindow *window;

@end

@implementation CR_ImpressionDetectionTests

- (void)setUp {
    self.window = [[UIWindow alloc] initWithFrame:(CGRect){0, 0, 1000, 1000}];
}

- (void)testInnerViewInside {
    UIView *superView = [[UIView alloc] initWithFrame:(CGRect){500, 500, 500, 500}];
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){250, 250, 250, 250}];
    [self.window addSubview:superView];
    [superView addSubview:innerView];

    BOOL visible = [CR_ImpressionDetector isViewVisible:innerView];

    XCTAssertTrue(visible);
}

- (void)testInnerViewOuside {
    UIView *superView = [[UIView alloc] initWithFrame:(CGRect){500, 500, 500, 500}];
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){500, 500, 250, 250}];
    [self.window addSubview:superView];
    [superView addSubview:innerView];

    BOOL visible = [CR_ImpressionDetector isViewVisible:innerView];

    XCTAssertFalse(visible);
}

- (void)testSuperViewOuside {
    UIView *superView = [[UIView alloc] initWithFrame:(CGRect){1000, 1000, 500, 500}];
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 250, 250}];
    [self.window addSubview:superView];
    [superView addSubview:innerView];

    BOOL visible = [CR_ImpressionDetector isViewVisible:innerView];

    XCTAssertFalse(visible);
}

- (void)testSuperViewHalfInside {
    UIView *superView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 500, 500}];
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){-250, -250, 500, 500}];
    [self.window addSubview:superView];
    [superView addSubview:innerView];

    BOOL visible = [CR_ImpressionDetector isViewVisible:innerView];

    XCTAssertTrue(visible);
}

- (void)testSuperSuperView {
    UIView *superSuperView = [[UIView alloc] initWithFrame:(CGRect){500, 500, 500, 500}];
    UIView *superView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 500, 500}];
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){250, 0, 250, 250}];
    [self.window addSubview:superSuperView];
    [superSuperView addSubview:superView];
    [superView addSubview:innerView];

    BOOL visible = [CR_ImpressionDetector isViewVisible:innerView];

    XCTAssertTrue(visible);
}

- (void)testViewHidden {
    UIView *superView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 500, 500}];
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 500, 500}];
    innerView.hidden = YES;
    [self.window addSubview:superView];
    [superView addSubview:innerView];

    BOOL visible = [CR_ImpressionDetector isViewVisible:innerView];

    XCTAssertFalse(visible);
}

- (void)testSuperViewHidden {
    UIView *superView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 500, 500}];
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 500, 500}];
    superView.hidden = YES;
    [self.window addSubview:superView];
    [superView addSubview:innerView];

    BOOL visible = [CR_ImpressionDetector isViewVisible:innerView];

    XCTAssertFalse(visible);
}


@end
