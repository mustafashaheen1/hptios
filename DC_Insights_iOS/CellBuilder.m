//
//  CellBuilder.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/12/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "CellBuilder.h"

@implementation CellBuilder
+ (InputScanViewCell *)createInputScanCell:(UITableView *)tableView
{
    InputScanViewCell *cell = (InputScanViewCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if(cell==nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellInputScan" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}
+ (InputViewCell *)createInputCell:(UITableView *)tableView
{
    InputViewCell *cell = (InputViewCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if(cell==nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellInput" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;

}
+ (SelectViewCell *)createSelectCell:(UITableView *)tableView
{
    SelectViewCell *cell = (SelectViewCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if(cell==nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellSelect" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

+ (DefectsViewCell *)createDefectCell:(UITableView *)tableView
{
    DefectsViewCell *cell = (DefectsViewCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if(cell==nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DefectsViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}
@end

