//
//  GWPreviewController.h
//  LoggingPad
//
//  Created by jimluo on 1/27/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWCurvesController.h"
#import "GWTextStackController.h"
#import "GWLegendController.h"

/**
 *  Preview and comment svg image, will be delegate and support for TextStack/Curves/Legend VC
 */
@interface GWPreviewController : UIViewController <GWPreviewCurvesControllerDelegate, GWPreviewTextStackControllerDelegate, GWPreviewLegendControllerDelegate>

/**
 *  called by Data VC, load svg to image
 *
 *  @param svgPath       svg file path
 *  @param svgLegendPath legend file path
 *  @param thumbnailPath thumbnail file path
 *  @param curvenames    curvenames for Curves VC
 */
- (void)showSvg:(NSString*)svgPath legend:(NSString*)svgLegendPath thumbnail:(NSString*)thumbnailPath curves:(NSArray*)curvenames;

/**
 *  gesture pan for input comment text
 *
 *  @param sender recognizer
 */
- (IBAction)handlePanGesture:(UIPanGestureRecognizer*)sender;

/**
 *  gesture tap for select curve to highlight
 *
 *  @param sender recognaizer
 */
- (IBAction)handleTapGesture:(UITapGestureRecognizer*)sender;

@end
