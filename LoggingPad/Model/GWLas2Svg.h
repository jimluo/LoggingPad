//
//  GWLas2Svg.h
//  LoggingPad
//
//  Created by jimluo on 2/28/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  convert las data to svg file, dependency GRMustache template library
 */
@interface GWLas2Svg : NSObject

/**
 *  static method to convert
 *
 *  @param lasName las filename
 *
 *  @return svg content string
 */
+ (NSString*)convert:(NSString*)lasName;

@end
