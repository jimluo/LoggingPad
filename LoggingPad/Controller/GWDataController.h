//
//  GWDataController.h
//  LoggingPad
//
//  Created by jimluo on 1/27/15.
//  Copyright (c) 2015 jimluo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Tableview show all data file for user select to preview
 *  find all las/svg file names in Docutment path
 *  user click cell will convert las to svg if this las never converted
 *  have a serach bar for user search data if cells more 
 */
@interface GWDataController : UITableViewController <UISearchBarDelegate>

@end
