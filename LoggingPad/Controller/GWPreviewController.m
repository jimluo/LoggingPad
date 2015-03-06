//
//  GWPreviewController.h
//  LoggingPad
//
//  Created by jimluo on 1/27/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "SVGKit.h"
#import "FCFileManager.h"
#import "GWPreviewController.h"
#import "GWCurvesController.h"
#import "GWTextStackController.h"
#import "GWLegendController.h"

@interface GWPreviewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView* scrollView;

/**
 *  cached image for show by SVGKit
 */
@property (strong, nonatomic) SVGKImage* svgImage;

/**
 *  cached legend image for Legend VC to show
 */
@property (strong, nonatomic) UIImage* svgLegendImage;

/**
 *  cahced curvename for Curves VC to show
 */
@property (strong, nonatomic) NSArray* curvenames;

/**
 *  show textedit for input
 */
@property (strong, nonatomic) CALayer* panLayerTextStatck;

/**
 *  show user select curve
 */
@property (strong, nonatomic) CAShapeLayer* tapLayerCurveSelect;

/**
 *  cached have input text for show
 */
@property (strong, nonatomic) CATextLayer* textLayers;

/**
 *  cached have selelcted curves to show
 */
@property (strong, nonatomic) NSMutableDictionary* curveLayers;
@property (strong, nonatomic) UITableViewController* lastPopoverTableView;

@end

@implementation GWPreviewController

#pragma mark - Managing the detail item

- (void)showSvg:(NSString*)svgPath legend:(NSString*)svgLegendPath thumbnail:(NSString*)thumbnailPath curves:(NSArray*)curvenames
{
    self.svgImage = [SVGKImage imageNamed:svgPath];

    SVGKImage* svgLegendImage = [SVGKImage imageNamed:svgLegendPath];
    if (svgLegendImage != nil) {
        self.svgLegendImage = [UIImage imageWithCGImage:svgLegendImage.UIImage.CGImage scale:0.5 orientation:UIImageOrientationUp];
    }

    if (![FCFileManager existsItemAtPath:thumbnailPath]) {
        [FCFileManager writeFileAtPath:thumbnailPath content:self.svgImage.UIImage];
    }

    self.curvenames = curvenames;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.toolbarHidden = NO;

    self.textLayers = [CATextLayer layer];
    [self.scrollView.layer addSublayer:self.textLayers];

    //self.scrollView addSubview:self.textInput
    self.panLayerTextStatck = [CALayer new];
    self.panLayerTextStatck.borderWidth = 1;
    self.panLayerTextStatck.anchorPoint = CGPointMake(0, 0);

    self.tapLayerCurveSelect = [CAShapeLayer new];
    self.tapLayerCurveSelect.borderWidth = 1;
    self.tapLayerCurveSelect.anchorPoint = CGPointMake(0, 0);

    self.curveLayers = [[NSMutableDictionary alloc] init];

    SVGKFastImageView* svgImageView = [[SVGKFastImageView alloc] initWithSVGKImage:self.svgImage];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.scrollView addSubview:svgImageView];
    });
}

- (void)createThumbnailBySvgImage:(NSString*)thumbnailPath
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.2);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* uiImage = UIGraphicsGetImageFromCurrentImageContext();

    [UIImagePNGRepresentation(uiImage) writeToFile:thumbnailPath atomically:YES];
    UIGraphicsEndImageContext();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* idSegue = [segue identifier];
    if ([idSegue isEqualToString:@"CurvesSegue"]) {
        GWCurvesController* curves = segue.destinationViewController;
        curves.delegate = self;
    }
    else if ([idSegue isEqualToString:@"TextStackSegue"]) {
        GWTextStackController* textStack = segue.destinationViewController;
        textStack.delegate = self;
    }
    else if ([idSegue isEqualToString:@"LegendSegue"]) {
        GWLegendController* legend = segue.destinationViewController;
        legend.delegate = self;
    }
    [self.lastPopoverTableView dismissViewControllerAnimated:YES completion:nil];
    self.lastPopoverTableView = segue.destinationViewController;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textInput
{
    [textInput resignFirstResponder]; //软键盘的撤回

    CATextLayer* textlayer = [CATextLayer layer];
    textlayer.contentsScale = [[UIScreen mainScreen] scale];
    textlayer.string = textInput.text;

    textlayer.anchorPoint = CGPointMake(0, 0);
    textlayer.frame = textInput.frame;

    textlayer.fontSize = 12.f;
    textlayer.foregroundColor = [UIColor blackColor].CGColor;

    [self.textLayers addSublayer:textlayer];

    [textInput removeFromSuperview];

    return YES;
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.view.layer addSublayer:self.panLayerTextStatck];
        self.panLayerTextStatck.position = [sender locationInView:self.view];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        [self.panLayerTextStatck removeFromSuperlayer];

        UITextField* textInput = [[UITextField alloc] initWithFrame:self.panLayerTextStatck.frame];
        textInput.delegate = self;
        textInput.backgroundColor = [UIColor lightGrayColor];
        textInput.textColor = [UIColor blackColor];
        textInput.font = [UIFont fontWithName:@"Arial-BoldMT" size:12.0];
        [textInput becomeFirstResponder];

        [self.view addSubview:textInput];

        NSLog(@"%f %f", textInput.layer.position.x, textInput.layer.position.y);
    }
    else {
        CGPoint startCrood = self.panLayerTextStatck.position;
        CGPoint newCoord = [sender translationInView:self.view];

        self.panLayerTextStatck.frame = CGRectMake(startCrood.x, startCrood.y, newCoord.x, newCoord.y);
    }
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer*)sender
{
    if (self.tapLayerCurveSelect.lineWidth == 2) {
        self.tapLayerCurveSelect.lineWidth = 1;
        [self.tapLayerCurveSelect removeFromSuperlayer];
    }
    else {
        CGPoint p = [sender locationInView:self.view];
        self.tapLayerCurveSelect = (CAShapeLayer*)[self.svgImage.CALayerTree hitTest:p];
        if (self.tapLayerCurveSelect != nil) {

            self.tapLayerCurveSelect.lineWidth = 2;
            [self.view.layer addSublayer:self.tapLayerCurveSelect];
        }
    }
}

#pragma mark - Delegate for GWCurvesController
- (NSArray*)curves
{
    return self.curvenames;
}

- (BOOL)selectedCurve:(NSString*)curvename
{
    if (self.curveLayers[curvename] == nil) {
        CAShapeLayer* curveLayer = (CAShapeLayer*)[self.svgImage layerWithIdentifier:curvename];
        if (curveLayer != nil) {
            curveLayer.lineWidth = 3;
            self.curveLayers[curvename] = curveLayer;
            [self.view.layer addSublayer:curveLayer];
        }
    }
    return YES;
}

#pragma mark - Delegate for GWCurvesController

- (NSDictionary*)textStack
{
    NSMutableDictionary* d = [[NSMutableDictionary alloc] init];
    for (CATextLayer* t in [self.textLayers sublayers]) {
        d[t.string] = t.string;
    }
    return [d copy];
}

- (BOOL)selectedText:(NSString*)text
{
    for (CATextLayer* t in [self.textLayers sublayers]) {
        if ([t.string isEqualToString:text]) {
            [t removeFromSuperlayer];
        }
    }
    return YES;
}

#pragma mark - Delegate for GWCurvesController
- (UIImage*)legendImage
{
    return self.svgLegendImage;
}

@end
