//
//  InsightsUITests.m
//  InsightsUITests
//
//  Created by Vineet Pareek on 19/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface InsightsUITests : XCTestCase

@end

@implementation InsightsUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"HomeScreenView"].buttons[@"ic cog"] tap];
    [[[app.navigationBars[@"SettingsView"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:0] tap];
    [app.buttons[@"Start New"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"Supplier"] childrenMatchingType:XCUIElementTypeButton].element tap];
    
    XCUIElementQuery *tablesQuery2 = tablesQuery;
    [tablesQuery2.staticTexts[@"BAY AREA HERBS"] tap];
    [[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"PO Number"] childrenMatchingType:XCUIElementTypeButton].element tap];
    [[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"2017-03-17"].staticTexts[@"000919146"] tap];
    [app.navigationBars[@"ContainerView"].buttons[@"ic menu forward"] tap];
    [tablesQuery2.staticTexts[@"CHIVE, FRESH HERB (8326365 / 042018)"] tap];
    [tablesQuery2.staticTexts[@"*Score"] swipeUp];
    [tablesQuery2.staticTexts[@"*Brand"] swipeUp];
    [[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"*Brand"] childrenMatchingType:XCUIElementTypeButton].element tap];
    [tablesQuery2.staticTexts[@"Exclusive Brand"] tap];
    [app.navigationBars[@"ProductView"].buttons[@"ic save"] tap];
    [app.navigationBars[@"InspectionStatusView"].buttons[@"ic remove"] tap];
    [app.alerts[@"Cancel Inspection?"].buttons[@"Ok"] tap];
    
}

@end
