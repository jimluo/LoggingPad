//
//  GWLegendController.h
//  LoggingPad
//
//  Created by jimluo on 3/3/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GWPreviewLegendControllerDelegate <NSObject>
- (UIImage*)legendImage;
@end

@interface GWLegendController : UIViewController

@property (strong, nonatomic) NSObject<GWPreviewLegendControllerDelegate>* delegate;
@end
