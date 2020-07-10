//
//  InsightsUnitTests.m
//  InsightsUnitTests
//
//  Created by Vineet Pareek on 4/5/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProductListManager.h"

@interface InsightsUnitTests : XCTestCase

@end

@implementation InsightsUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        ProductListManager *productListManager = [[ProductListManager alloc]init];
        NSArray* list = [productListManager getProductsList:YES];
    }];
}

-(void)testListOfProducts {
    ProductListManager *productListManager = [[ProductListManager alloc]init];
    NSArray* list = [productListManager getProductsList:YES];
    NSLog(@"list is %ld", [list count]);
    XCTAssert([list count]>0, @"product list is empty");
}

@end
