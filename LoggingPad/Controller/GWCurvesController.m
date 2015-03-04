//
//  UICurvesController.m
//  LoggingPad
//
//  Created by jimluo on 2/5/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "GWCurvesController.h"

@interface GWCurvesController ()

@end

@implementation GWCurvesController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.delegate curves] count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CurvesReuseID" forIndexPath:indexPath];
    cell.textLabel.text = [self.delegate curves][indexPath.row];

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.delegate selectedCurve:cell.textLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
