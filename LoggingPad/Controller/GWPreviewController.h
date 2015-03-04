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

@interface GWPreviewController : UIViewController <GWPreviewCurvesControllerDelegate, GWPreviewTextStackControllerDelegate, GWPreviewLegendControllerDelegate>

- (void)showSvg:(NSString*)svgPath legend:(NSString*)svgLegendPath thumbnail:(NSString*)thumbnailPath curves:(NSArray*)curvenames;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer*)sender;
- (IBAction)handleTapGesture:(UITapGestureRecognizer*)sender;

@end
