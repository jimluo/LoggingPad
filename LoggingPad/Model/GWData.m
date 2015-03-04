//
//  GWData.m
//  LoggingPad
//
//  Created by jimluo on 1/15/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "GWData.h"

@implementation GWData

@synthesize well, curves;

+ (id)GWCreateDataByPath:(NSString*)path
{
    GWData* data = nil;
    NSString* ext = [[path pathExtension] lowercaseString];
    if ([ext isEqualToString:@"las"]) {
        data = [[GWDataLAS alloc] init];
    }

    if (![data loadData:path]) {
        return nil;
    }
    return data;
}

- (id)init
{
    self = [super init];

    if (self != nil) {
        well = [[NSMutableDictionary alloc] init];
        curves = [[NSMutableArray alloc] init];
        curveData = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (BOOL)loadData:(NSString*)path
{
    return TRUE;
}

- (NSArray*)readData:(NSString*)curveName depthStart:(double)depthStart depthStop:(double)depthStop
{
    double start = [well[@"STRT"] doubleValue];
    double step = [well[@"STEP"] doubleValue];
    NSUInteger idxStart = (depthStart - start) / step;
    NSUInteger idxStop = (depthStop - start) / step;

    return [curveData[curveName] subarrayWithRange:NSMakeRange(idxStart, idxStop)];
}

- (NSArray*)readAllData:(NSString*)curveName
{
    return curveData[curveName];
}

@end
