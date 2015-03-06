//
//  GWDataLAS.m
//  LoggingPad
//
//  Created by jimluo on 1/15/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "GWData.h"
#import "YOLO.h"

@implementation GWDataLAS

- (BOOL)loadData:(NSString*)path
{
    NSError* err = nil;
    NSArray* linesOfText =
        [[NSString stringWithContentsOfFile:path
                                   encoding:NSUTF8StringEncoding
                                      error:&err]
            componentsSeparatedByString:@"\n"];
    if (err != nil) {
        NSLog(@"Reading error  %@", err);
        return FALSE;
    }
    NSLog(@"Reading %@ lines: %d", [path lastPathComponent], (int)[linesOfText count]);

    NSMutableArray* dataArray = [self parseData:linesOfText];
    for (int i = 0; i < self.curves.count; i++) {
        NSString* name = self.curves[i];
        curveData[name] = [NSArray arrayWithArray:dataArray[i]];
    }

    NSDictionary* well = [self well];
    self.details = [NSString stringWithFormat:@"Depth:%@~%@ Well:%@ Date:%@", well[@"STRT"], well[@"STOP"], well[@"WELL"], well[@"Date"]];
    [self.details stringByAppendingFormat:@"+%@", self.curves.join(@",")];

    return TRUE;
}

/**
 *  parse each text line, include sections: well/curve/Ascii data
 *
 *  @param linesOfText text lines
 *
 *  @return data array
 */
- (NSMutableArray*)parseData:(NSArray*)linesOfText
{
    NSString* sectionID = @"";
    NSMutableArray* dataArray = [[NSMutableArray alloc] init];
    NSSet* depthInWell = [NSSet setWithArray:@[ @"STRT", @"STOP", @"STEP" ]];

    for (NSString* line in linesOfText) {
        if (![line hasPrefix:@"#"]) {
            if ([line hasPrefix:@"~"]) {
                sectionID = [line substringToIndex:2];
            }
            else if ([sectionID isEqualToString:@"~W"]) { //section well
                NSString* nameUnitValue = [[line componentsSeparatedByString:@":"] firstObject];
                NSString* nameUnit = [[nameUnitValue componentsSeparatedByString:@" "] firstObject];
                NSString* name = [[nameUnitValue componentsSeparatedByString:@"."] firstObject];
                NSString* value = [[nameUnitValue substringFromIndex:[nameUnit length]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([depthInWell containsObject:name]) {
                    self.well[name] = [NSNumber numberWithFloat:[value floatValue]];
                }
                else {
                    self.well[name] = value;
                }
            }
            else if ([sectionID isEqualToString:@"~C"]) { //section curve
                [self.curves addObject:[[line componentsSeparatedByString:@"."] firstObject]];
                [dataArray addObject:[[NSMutableArray alloc] init]];
            }
            else if ([sectionID isEqualToString:@"~A"]) { //section ascii data
                NSArray* dataRow = [line componentsSeparatedByString:@" "];
                for (int i = 0; i < dataRow.count; i++) {
                    NSNumber* d = [NSNumber numberWithFloat:[dataRow[i] floatValue]];
                    [dataArray[i] addObject:d];
                }
            }
        }
    }

    return dataArray;
}

@end
