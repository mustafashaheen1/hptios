//
//  CompleteInspectionSubTableViewCell.m
//  Insights
//
//  Created by Shyam Ashok on 1/2/15.
//  Copyright (c) 2015 Yottamark. All rights reserved.
//

#import "CompleteInspectionSubTableViewCell.h"

@implementation CompleteInspectionSubTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.frame = CGRectMake(0, 0, 300, 50);
        UITableView *subMenuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        subMenuTableView.tag = 100;
        subMenuTableView.delegate = self;
        subMenuTableView.dataSource = self;
        subMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:subMenuTableView]; // add it cell
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UITableView *subMenuTableView =(UITableView *) [self viewWithTag:100];
    subMenuTableView.scrollEnabled = NO;
    [subMenuTableView reloadData];
    subMenuTableView.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5,self.bounds.size.height-5);//set the frames for tableview
}

//manage datasource and  delegate for submenu tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.containersGLobalArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = [self.containersGLobalArray objectAtIndex:section];
    return [NSString stringWithFormat:@"%@", [[dict allKeys] objectAtIndex:0]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [self.containersGLobalArray objectAtIndex:section];
    NSArray *array = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"cellID %d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    NSDictionary *dict = [self.containersGLobalArray objectAtIndex:indexPath.section];
    NSArray *array = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];

    cell.textLabel.text = [NSString stringWithFormat:@"%@", [array objectAtIndex:indexPath.row]];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

@end
