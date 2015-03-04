//
//  UICurvesController.h
//  LoggingPad
//
//  Created by jimluo on 2/5/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GWPreviewCurvesControllerDelegate <NSObject>
- (NSArray*)curves;
- (BOOL)selectedCurve:(NSString*)curvename;
@end

@interface GWCurvesController : UITableViewController

@property (strong, nonatomic) NSObject<GWPreviewCurvesControllerDelegate>* delegate;

@end
