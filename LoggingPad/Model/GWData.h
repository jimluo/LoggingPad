//
//  GWData.h
//  LoggingPad
//
//  Created by jimluo on 1/15/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GWData : NSObject {
@protected
    NSString* filePath;
    NSMutableDictionary* curveData;
}

@property (strong, nonatomic, readonly) NSMutableDictionary* well;
@property (strong, nonatomic, readonly) NSMutableArray* curves;
@property (strong, nonatomic) NSString* details;

+ (id)GWCreateDataByPath:(NSString*)path;

- (BOOL)loadData:(NSString*)path;
- (NSArray*)readData:(NSString*)curveName depthStart:(double)depthStart depthStop:(double)depthStop;
- (NSArray*)readAllData:(NSString*)curveName;

@end

@interface GWDataLAS : GWData
@end

@interface GWDataLIS : GWData
@end

@interface GWDataWIS : GWData
@end