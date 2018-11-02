//
//  BasicTestOfNothing.m
//  
//
//  Created by Yahor Paulikau on 11/2/18.
//

#import <XCTest/XCTest.h>


@interface BasicTestOfNothing : XCTestCase

@end

@implementation BasicTestOfNothing


- (void)testExample {
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //XCTAssertNotNil(appDelegate, @"Cannot find AppDelegate instance");
    
    UIApplication *app   = [UIApplication sharedApplication];

}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
