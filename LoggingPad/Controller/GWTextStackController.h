//
//  UITextStackController.h
//  LoggingPad
//
//  Created by jimluo on 2/5/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GWPreviewTextStackControllerDelegate <NSObject>
- (NSDictionary*)textStack;
- (BOOL)selectedText:(NSString*)text;
@end


@interface GWTextStackController : UITableViewController

@property(strong, nonatomic) NSObject<GWPreviewTextStackControllerDelegate>* delegate;

@end
