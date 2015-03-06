//
//  GWDataTests.m
//  LoggingPad
//
//  Created by jimluo on 3/6/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <YOLOKit/YOLO.h>
#import <OCMockito/OCMockito.h>
#import "GWData.h"

@interface GWDataTests : XCTestCase
@property (strong, nonatomic) NSDictionary* well;
@property (strong, nonatomic) NSArray* curves;
@property (strong, nonatomic) NSArray* data;
@end

@implementation GWDataTests

- (void)setUp
{
    [super setUp];

    self.well = @{
        @"STRT" : @1000.0,
        @"STOP" : @1050.0,
        @"STEP" : @10,
        @"WELL" : @"GU98",
        @"DATE" : @"1999.9.9"
    };
    self.curves = @[ @"DEPTH", @"WTEMP" ];
    self.data = @[ @[ @1000.0, @1010, @1020, @1030, @1040 ], @[ @30, @31, @32, @33, @34 ] ];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSArray*)newLasContent
{
    NSMutableArray* wellArray = [NSMutableArray new];
    for (NSString* k in self.well.allKeys) {
        wellArray.push([NSString stringWithFormat:@"%@.M %@:comments", k, self.well[k]]);
    }
    NSMutableArray* curveArray = [NSMutableArray new];
    for (NSString* k in self.curves) {
        curveArray.push([NSString stringWithFormat:@"%@.unit : comments", k]);
    }
    NSMutableArray* dataArray = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
        dataArray.push(@[ self.data[0][i], self.data[1][i] ].join(@" "));
    }

    NSArray* lasContent = @[ @"~Well", wellArray, @"~Curve", curveArray, @"~Ascii", dataArray ].flatten;

    return lasContent;
}

- (void)testParseData
{
    GWDataLAS* dataLAS = [GWDataLAS new];
    NSMutableArray* actulData = [dataLAS parseData:[self newLasContent]];

    XCTAssertEqualObjects(self.well, dataLAS.well, "well ?");
    XCTAssertEqualObjects(self.curves, dataLAS.curves, "curves ?");
    XCTAssertEqualObjects(self.data, actulData, "");
}

- (void)testPerformance
{
    GWDataLAS* dataLAS = [GWDataLAS new];
    [self measureBlock:^{
        [dataLAS parseData:[self newLasContent]];
    }];
}

@end
