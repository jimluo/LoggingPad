//
//  GWDataController.m
//  LoggingPad
//
//  Created by jimluo on 1/27/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import "FCFileManager.h"
#import "YOLO.h"

#import "GWDataController.h"
#import "GWPreviewController.h"
#import "GWData.h"
#import "GWLas2Svg.h"

@interface GWDataController () <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar* searchBar;
@property (strong, nonatomic) NSMutableArray* dataNamesBySearch;
@property (strong, nonatomic) NSMutableDictionary* dataThumbnail;
@property (strong, nonatomic) NSMutableDictionary* dataDetails;

@end

@implementation GWDataController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.contentOffset = CGPointMake(0, 44);

    NSString* plistPath = [FCFileManager pathForPlistNamed:@"dataDetails"];
    self.dataDetails = [[NSDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];

    self.dataThumbnail = [NSMutableDictionary new];
    NSString* docPath = [FCFileManager pathForDocumentsDirectory];
    for (NSString* name in [FCFileManager listFilesInDirectoryAtPath:docPath withExtension:@"las"]) {
        NSString* thumbnailPath = [name stringByAppendingPathExtension:@"svg.png"];
        UIImage* thumbnail = [FCFileManager readFileAtPathAsImage:thumbnailPath];
        if (thumbnail != nil) {
            self.dataThumbnail[[name lastPathComponent]] = thumbnail;
        }
    }

    //copy MIT24.las from bundle to docPath if docPath haven't las files for first use this app
    if ([self.dataThumbnail count] < 1) {
        NSString* thumbnailPath = [FCFileManager pathForMainBundleDirectoryWithPath:@"MIT24.las.svg.png"];
        self.dataThumbnail[@"MIT24.las"] = [FCFileManager readFileAtPathAsImage:thumbnailPath];

        for (NSString* name in @[ @"MIT24.las", @"MIT24.las.svg", @"MIT24.las.legend.svg", @"MIT24.las.svg.png" ]) {
            NSString* src = [FCFileManager pathForMainBundleDirectoryWithPath:name];
            NSString* dst = [FCFileManager pathForDocumentsDirectoryWithPath:name];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [FCFileManager copyItemAtPath:src toPath:dst error:nil];
            });
        }
    }

    self.dataNamesBySearch = [[self.dataThumbnail allKeys] mutableCopy];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PreviewSegue"]) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        NSString* name = self.dataNamesBySearch[indexPath.row];
        NSString* lasPath = [FCFileManager pathForDocumentsDirectoryWithPath:name];
        NSString* svgLegendPath = [lasPath stringByAppendingPathExtension:@"legend.svg"];
        NSString* svgPath = [lasPath stringByAppendingPathExtension:@"svg"];
        NSString* thumbnailPath = [svgPath stringByAppendingPathExtension:@"png"];

        if (![FCFileManager existsItemAtPath:svgPath]) {
            self.dataDetails[name] = [GWLas2Svg convert:lasPath];
            NSString* plistPath = [FCFileManager pathForPlistNamed:@"dataDetails"];
            [self.dataDetails writeToFile:plistPath atomically:NO];
        }

        if ([FCFileManager existsItemAtPath:svgPath]) {
            NSString* details = self.dataDetails[name];
            NSString* curvenames = details.split(@"+")[1];//detail+curvenames
            NSArray* curves = curvenames.split(@",");
            [[segue destinationViewController] showSvg:svgPath legend:svgLegendPath thumbnail:thumbnailPath curves:curves];
        }

        if (![FCFileManager existsItemAtPath:thumbnailPath]) {
            self.dataThumbnail[name] = [FCFileManager readFileAtPathAsImage:thumbnailPath];
        }
    }
    else {
        [segue destinationViewController];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataNamesBySearch.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SVGReuseID" forIndexPath:indexPath];

    NSString* name = self.dataNamesBySearch[indexPath.row];

    cell.textLabel.text = name;
    NSString* details = self.dataDetails[name];
    cell.detailTextLabel.text = details.split(@"+")[0];
    if ((self.dataThumbnail[name] != nil) && [self.dataThumbnail[name] isKindOfClass:[UIImage class]]) {
        cell.imageView.image = self.dataThumbnail[name];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 120;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString* name = self.dataNamesBySearch[indexPath.row];
        [self.dataNamesBySearch removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        [FCFileManager removeItemAtPath:name];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - Search Bar Delegate
- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    if ([self.searchBar.text length] > 0) {
        [self doSearch];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    [self.searchBar resignFirstResponder];

    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;

    self.dataNamesBySearch = [self.dataNamesBySearch initWithArray:[self.dataThumbnail allKeys]];

    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self.searchBar resignFirstResponder];
    [self doSearch];
}

- (void)doSearch
{
    NSString* searchText = self.searchBar.text;

    [self.dataNamesBySearch removeAllObjects];
    for (NSString* name in [self.dataThumbnail allKeys]) {
        if ([name containsString:searchText]) {
            [self.dataNamesBySearch addObject:name];
        }
    }

    [self.tableView reloadData];
}

// Change the sort key used when fetching object.
//- (IBAction)changeSortKey:(id)sender
//{
//    switch ([(UISegmentedControl*)sender selectedSegmentIndex]) {
//    case 0: {
//        //            [[NSUserDefaults standardUserDefaults] setObject:SORT_KEY_RATING forKey:WB_SORT_KEY];
//        //            [self fetchAllBeers];
//        [self.tableView reloadData];
//    } break;
//    case 1: {
//        //            [[NSUserDefaults standardUserDefaults] setObject:SORT_KEY_NAME forKey:WB_SORT_KEY];
//        //            [self fetchAllBeers];
//        [self.tableView reloadData];
//    } break;
//    default:
//        break;
//    }
//}

@end
