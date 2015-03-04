//
//  GWLas2Svg.m
//  LoggingPad
//
//  Created by jimluo on 2/28/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "GWLas2Svg.h"
#import "GWData.h"
#import "GRMustache.h"
#import "FCFileManager.h"

@implementation GWLas2Svg

const int HeightCurveInLegend = 30;
const int WidthTrackColumn = 30;
const int Pixels1M = 20;
const int DepthText25M = 25;
const int TextYOffset = 5;

+ (NSNumber*)getTextXMidFromInfoData:(NSDictionary*)info track1:(NSString*)t1 track2:(NSString*)t2
{
    return [NSNumber numberWithDouble:(([info[t1] doubleValue] + [info[t2] doubleValue]) / 2)];
}

+ (void)createTrack3LegendCurves:(NSDictionary*)infoDataConst curveInTrack:(NSMutableArray*)curves
{
    NSDictionary* infoCurveRadii = @{ @"CurveName" : @"R",
        @"CurveStroke" : @"brown",
        @"LineLeft" : infoDataConst[@"Track3X"],
        @"LineRight" : infoDataConst[@"width"],
        @"TextXMid" : [GWLas2Svg getTextXMidFromInfoData:infoDataConst track1:@"Track3X" track2:@"width"],
        @"CurvePoints" : @""
    };

    NSMutableArray* curveRadii = [NSMutableArray new];
    for (NSDictionary* curve in curves) {
        if ([curve[@"CurveName"] hasPrefix:@"R"]) {
            [curveRadii addObject:curve];
        }
    }

    for (id curve in curveRadii) {
        [curves removeObject:curve];
    }

    int j = 1;
    for (int i = 0; i < 24; i += 10, j++) {
        NSMutableDictionary* radii = [infoCurveRadii mutableCopy];
        radii[@"CurveName"] = [NSString stringWithFormat:@"R%02d", i + 1];
        radii[@"CurveMin"] = [NSNumber numberWithFloat:(3.1 - i * 0.035)];
        radii[@"CurveMax"] = [NSNumber numberWithFloat:(4.1 - i * 0.035)];
        radii[@"TextY"] = [NSNumber numberWithInt:j * 30]; //HeightCurveInLegend,
        radii[@"LineY"] = [NSNumber numberWithInt:j * 30 + 5];
        [curves addObject:radii];
    }
}

+ (void)createTrack3Curves:(NSDictionary*)infoDataConst curveInTrack:(NSMutableDictionary*)infoCurveInTrack
{
    NSDictionary* infoCurveRadii = @{ @"CurveName" : @"R",
        @"CurveStroke" : @"black",
        @"LineLeft" : infoDataConst[@"Track3X"],
        @"LineRight" : infoDataConst[@"width"],
        @"TextXMid" : [GWLas2Svg getTextXMidFromInfoData:infoDataConst track1:@"Track3X" track2:@"width"], //(infoData[@"Track3X"] + infoData[@"width"]) / 2,
    };

    for (int i = 0; i < 24; ++i) {
        NSMutableDictionary* radii = [infoCurveRadii mutableCopy];
        radii[@"CurveName"] = [NSString stringWithFormat:@"R%02d", i + 1];
        radii[@"CurveMin"] = [NSNumber numberWithDouble:(51 - i * 0.6)];
        radii[@"CurveMax"] = [NSNumber numberWithDouble:(71 - i * 0.6)];
        if (i % 10 == 0) {
            radii[@"CurveStroke"] = @"brown";
        }
        infoCurveInTrack[radii[@"CurveName"]] = radii;
    }
}

+ (void)createTrack2Curves:(NSDictionary*)infoDataConst curveInTrack:(NSMutableDictionary*)infoCurveInTrack
{
    NSDictionary* infoCurveRD = @{ @"LineLeft" : infoDataConst[@"Track2X"],
        @"LineRight" : infoDataConst[@"Track3X"],
        @"TextXMid" : [GWLas2Svg getTextXMidFromInfoData:infoDataConst track1:@"Track2X" track2:@"Track3X"] };

    NSArray* RD = @[ @[ @"MXRD", @"red" ], @[ @"AVRD", @"green" ], @[ @"MNRD", @"blue" ] ];
    for (NSArray* curve in RD) {
        NSMutableDictionary* rd = [infoCurveRD mutableCopy];
        rd[@"CurveName"] = curve[0];
        rd[@"CurveStroke"] = curve[1];
        rd[@"CurveMin"] = @51;
        rd[@"CurveMax"] = @71;

        infoCurveInTrack[rd[@"CurveName"]] = rd;
    }
    //    infoCurveInTrack[@"MINR"][@"CurveMax"] = @0;
}

+ (void)createTrack1Curves:(NSDictionary*)infoDataConst curveInTrack:(NSMutableDictionary*)infoCurveInTrack
{
    NSDictionary* infoCurveMisc = @{ @"LineLeft" : infoDataConst[@"Track1X"],
        @"LineRight" : infoDataConst[@"TrackDepthX"],
        @"TextXMid" : [GWLas2Svg getTextXMidFromInfoData:infoDataConst track1:@"Track1X" track2:@"TrackDepthX"] };

    NSArray* misc = @[ @[ @"LSPD", @"blue", @-20, @0 ], @[ @"LTEN", @"black", @-1500, @-1000 ], @[ @"CCL", @"brown", @10000, @30000 ], @[ @"GR", @"green", @0, @200 ], @[ @"WTEMP", @"red", @0, @50 ] ];
    for (NSArray* curve in misc) {
        NSMutableDictionary* misc = [infoCurveMisc mutableCopy];
        misc[@"CurveName"] = curve[0];
        misc[@"CurveStroke"] = curve[1];
        misc[@"CurveMin"] = curve[2];
        misc[@"CurveMax"] = curve[3];

        infoCurveInTrack[misc[@"CurveName"]] = misc;
    }
}

+ (NSMutableDictionary*)fillDataInfoFromLas:(GWData*)las
{
    NSDictionary* infoDataConst = @{
        @"title" : @"logging curves",
        @"width" : @640.0,
        @"height" : @1800.0,
        @"heightLegend" : @2000.0,
        @"WidthTrack" : @200.0,
        @"WidthTrackColumn" : @20,
        @"Track1X" : @0.0,
        @"Track2X" : @240.0,
        @"Track3X" : @440.0,
        @"TrackDepthX" : @200.0,
        @"TrackDepthWidth" : @40.0,
        @"Curves" : @"",
        @"DepthText" : @"",
        @"TrackColumn" : @"",
        @"TrackRow1M" : @"",
        @"TrackRow5M" : @""
    };

    NSMutableDictionary* infoCurveInTrack = [NSMutableDictionary new];
    [GWLas2Svg createTrack1Curves:infoDataConst curveInTrack:infoCurveInTrack];
    [GWLas2Svg createTrack2Curves:infoDataConst curveInTrack:infoCurveInTrack];
    [GWLas2Svg createTrack3Curves:infoDataConst curveInTrack:infoCurveInTrack];

    NSDictionary* curveYInTrackConst = @{ infoDataConst[@"Track1X"] : @1,
        infoDataConst[@"Track2X"] : @1,
        infoDataConst[@"Track3X"] : @1 };
    NSMutableDictionary* curveYInTrack = [curveYInTrackConst mutableCopy];

    NSMutableArray* curves = [NSMutableArray new];
    for (NSString* c in [las curves]) {
        if ([infoCurveInTrack objectForKey:c] == nil) {
            continue;
        }

        NSMutableDictionary* curve = [infoCurveInTrack[c] mutableCopy];
        double min = [curve[@"CurveMin"] doubleValue];
        double max = [curve[@"CurveMax"] doubleValue];
        double left = [curve[@"LineLeft"] doubleValue];
        double right = [curve[@"LineRight"] doubleValue];
        double gain = (right - left) / (max - min);
        double offset = right - gain * max;

        NSArray* data = [las readAllData:c];
        NSMutableArray* pt = [NSMutableArray arrayWithCapacity:[data count]];
        for (int i = 0; i < [data count]; i++) {
            double d = [data[i] doubleValue];
            pt[i] = [NSString stringWithFormat:@"%d,%d", (int)(d * gain + offset), i];
        }

        [curve setValue:[pt componentsJoinedByString:@" "] forKey:@"CurvePoints"];
        curve[@"CurvePoints"] = [pt componentsJoinedByString:@" "];
        curve[@"TextY"] = [NSNumber numberWithInt:[curveYInTrack[curve[@"LineLeft"]] intValue] * HeightCurveInLegend];
        curve[@"LineY"] = [NSNumber numberWithInt:[curve[@"TextY"] intValue] + TextYOffset];

        curveYInTrack[curve[@"LineLeft"]] = [NSNumber numberWithInt:[curveYInTrack[curve[@"LineLeft"]] intValue] + 1];
        [curves addObject:curve];
    }
    NSMutableDictionary* infoData = [infoDataConst mutableCopy];
    infoData[@"height"] = [NSNumber numberWithUnsignedInteger:[[las readAllData:@"LSPD"] count]];
    infoData[@"heightLegend"] = [NSNumber numberWithInt:[curveYInTrack[infoData[@"Track3X"]] intValue] * HeightCurveInLegend];
    infoData[@"Curves"] = curves;

    return infoData;
}

+ (NSString*)convert:(NSString*)lasName
{
    GWData* las = [GWData GWCreateDataByPath:lasName];
    if (las != nil) {
        return nil;
    }
    NSMutableDictionary* infoData = [self fillDataInfoFromLas:las];

    NSMutableArray* cols = [NSMutableArray new];
    unsigned long numCol = [infoData[@"width"] unsignedIntegerValue] / [infoData[@"WidthTrackColumn"] intValue];
    for (int i = 0; i < numCol; i++) {
        [cols addObject:@{ @"TrackColumnX" : [NSNumber numberWithInt:i * [infoData[@"WidthTrackColumn"] intValue]] }];
    }
    infoData[@"TrackColumn"] = cols;

    NSMutableArray* row1Ms = [NSMutableArray new];
    unsigned long numRow1M = [infoData[@"height"] unsignedIntegerValue] / Pixels1M;
    for (int i = 0; i < numRow1M; i++) {
        [row1Ms addObject:@{ @"TrackRow1MY" : [NSNumber numberWithInt:i * Pixels1M] }];
    }
    infoData[@"TrackRow1M"] = row1Ms;

    NSMutableArray* row5Ms = [NSMutableArray new];
    int depthStart = (int)ceil(([[las well][@"STRT"] doubleValue] + 5) / 10.0) * 10;
    NSMutableArray* depthTextes = [NSMutableArray new];
    unsigned long numRow5M = [infoData[@"height"] unsignedIntegerValue] / Pixels1M / 5;
    for (int i = 0; i < numRow5M; i++) {
        [row5Ms addObject:@{ @"TrackRow5MY" : [NSNumber numberWithInt:i * Pixels1M * 5] }];
        if (i % 5 == 0) {
            NSDictionary* depthText = @{ @"DepthText25MY" : [NSNumber numberWithInt:i * 5 * Pixels1M + TextYOffset],
                @"DepthText25M" : [NSString stringWithFormat:@"%d", depthStart - i * 5] };
            [depthTextes addObject:depthText];
        }
    }
    infoData[@"TrackRow5M"] = row5Ms;
    infoData[@"DepthText"] = depthTextes;

    NSString* lasPath = [FCFileManager pathForDocumentsDirectoryWithPath:lasName];
    NSString* lasTemplatePath = [FCFileManager pathForDocumentsDirectoryWithPath:@"las.mustache"];
    NSString* legendTemplatePath = [FCFileManager pathForDocumentsDirectoryWithPath:@"legend.mustache"];
    NSString* svgPath = [lasPath stringByAppendingPathExtension:@"svg"];
    NSString* legendPath = [lasPath stringByAppendingPathExtension:@"legend.svg"];
    NSError* err = nil;

    GRMustacheTemplate* template = [GRMustacheTemplate templateFromContentsOfFile:lasTemplatePath error:&err];
    NSString* rendering = [template renderObject:infoData error:NULL];
    [rendering writeToFile:svgPath atomically:NO encoding:NSUTF8StringEncoding error:&err];

    template = [GRMustacheTemplate templateFromContentsOfFile:legendTemplatePath error:&err];
    rendering = [template renderObject:infoData error:NULL];
    [rendering writeToFile:legendPath atomically:NO encoding:NSUTF8StringEncoding error:&err];

    return las.details;
}

@end
