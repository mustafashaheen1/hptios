//
//  CellBuilder.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/12/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//
//  This static class is an aid to create table view cells without lots of messy code.  
//
#import <Foundation/Foundation.h>
#import "InputScanViewCell.h"
#import "InputViewCell.h"
#import "SelectViewCell.h"
#import "DefectsViewCell.h"

@interface CellBuilder : NSObject
+ (InputScanViewCell *)createInputScanCell:(UITableView *)tableView;
+ (InputViewCell *)createInputCell:(UITableView *)tableView;
+ (SelectViewCell *)createSelectCell:(UITableView *)tableView;
+ (DefectsViewCell *)createDefectCell:(UITableView *)tableView;
@end
