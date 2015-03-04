//
//  GWLegendController.m
//  LoggingPad
//
//  Created by jimluo on 3/3/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "GWLegendController.h"

@interface GWLegendController ()
@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@end

@implementation GWLegendController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage* img = self.delegate.legendImage;
    self.imageView.image = img;

//    CGRect newFrame = self.imageView.frame;
//    newFrame.size.width = img.size.width;
//    newFrame.size.width = img.size.height;
//    self.imageView.frame = newFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
