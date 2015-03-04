//
//  UITextStackController.m
//  LoggingPad
//
//  Created by jimluo on 2/5/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "GWTextStackController.h"

@interface GWTextStackController ()

@end

@implementation GWTextStackController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.delegate textStack] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextStackReuseID" forIndexPath:indexPath];
    cell.textLabel.text = [[self.delegate textStack] allKeys][indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.delegate selectedText:cell.textLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
