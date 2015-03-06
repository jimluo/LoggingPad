//
//  GWData.h
//  LoggingPad
//
//  Created by jimluo on 1/15/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Well logging data, include well/curve/misc and data
 */
@interface GWData : NSObject {
@protected
    NSString* filePath;
    NSMutableDictionary* curveData;
}

@property (strong, nonatomic, readonly) NSMutableDictionary* well;
@property (strong, nonatomic, readonly) NSMutableArray* curves;
@property (strong, nonatomic) NSString* details;

/**
 *  Create a new GWData from file path
 *
 *  @param path data file path
 *
 *  @return GWData instance
 */
+ (id)GWCreateDataByPath:(NSString*)path;

/**
 *  load data from file path, subclass will parse data[template DP]
 *
 *  @param path data file path
 *
 *  @return can this data loaded OK?
 */
- (BOOL)loadData:(NSString*)path;

/**
 *  read data array by curvename and depth range
 *
 *  @param curveName  need data of curve name
 *  @param depthStart depth range start
 *  @param depthStop  depth range stop
 *
 *  @return data array. sybclass will decided data type.
 */
- (NSArray*)readData:(NSString*)curveName depthStart:(double)depthStart depthStop:(double)depthStop;

/**
 *  read data array of curve name
 *
 *  @param curveName need data of curve name
 *
 *  @return data array. sybclass will decided data type.
 */
- (NSArray*)readAllData:(NSString*)curveName;

@end

/**
 *  LAS data file
 */
@interface GWDataLAS : GWData
- (NSMutableArray*)parseData:(NSArray*)linesOfText;
@end

/**
 *  LIS and DLIS data file
 */
@interface GWDataLIS : GWData
@end

/**
 *  WATCH app data WIS file
 */
@interface GWDataWIS : GWData
@end