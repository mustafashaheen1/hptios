//
//  InspectionDefectTableTableViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InspectionDefectTableTableViewCell.h"

@implementation InspectionDefectTableTableViewCell

@synthesize inspectionDefectTableViewCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 300, 50);
        self.subMenuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.subMenuTableView.tag = 100;
        self.subMenuTableView.delegate = self;
        self.subMenuTableView.dataSource = self;
        self.subMenuTableView.scrollEnabled = YES;
        self.subMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.subMenuTableView]; // add it cell
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSMutableAttributedString*)getUnderlineTextForString:(NSString*)string {
    NSMutableAttributedString *underlineText = [[NSMutableAttributedString alloc] initWithString:string];
    [underlineText addAttribute:NSUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:2]
                          range:(NSRange){0,[string length]}];
    [underlineText addAttribute:NSUnderlineColorAttributeName
                          value:[UIColor blueColor]
                          range:(NSRange){0,[string length]}];

    return underlineText;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //UITableView *subMenuTableView =(UITableView *) [self viewWithTag:100];
    self.subMenuTableView.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5, self.bounds.size.height-5);//set the frames for tableview
}

//manage datasource and  delegate for submenu tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numberOfSections = 1 + [self.allDefectsList count];
    return numberOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        Defect *defect = [self.allDefectsList objectAtIndex:section - 1];
        if([defect.severities count] > 0)
            return 1 + [defect.severities count];
        else
            return 1+1; //for boolean defects
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    cell.detailTextLabel.textColor = [UIColor blackColor];
    if (indexPath.section == 0) {
        
        //NSLog(@"row %d section %d", indexPath.row, indexPath.section);
        cell.textLabel.text = [NSString stringWithFormat:@"Avg. %@",self.ratingName];
        UIFont *myFont = [UIFont fontWithName: @"Helvetica" size: 13.0];
        cell.textLabel.font  = myFont;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.ratingValue];
        cell.detailTextLabel.attributedText = [self getUnderlineTextForString:[NSString stringWithFormat:@"%@",self.ratingValue]];
        cell.detailTextLabel.font = myFont;
    } else {
        Defect *defect = [self.allDefectsList objectAtIndex:indexPath.section - 1];
        //NSLog(@"row %d section %d", indexPath.row, indexPath.section);
        if (indexPath.row == 0) {

        } else {
            if([defect.severities count]==0) {
                cell.textLabel.text = [NSString stringWithFormat:@"  %@",defect.name];
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
            } else {
                
                Severity *severity = [defect.severities objectAtIndex:indexPath.row - 1];
                cell.textLabel.text = [NSString stringWithFormat:@"  %@ - %@",defect.name,severity.name];
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f%%", severity.inputOrCalculatedPercentage];
                cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self showStarRatingValueAlert];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    if (indexPath.section == 0) {
        return 15;
    } else {
        if (indexPath.row == 0)
            return 1.0f;
        else
        return 15.0f;
    }
}

- (void) showStarRatingValueAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter New Average Score between 1 and 5"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    UITextField* textfield = [alert textFieldAtIndex:0];
    textfield.text = [NSString stringWithFormat:@"%@",self.ratingValue];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) { //handle OK and cancel
        if(buttonIndex == alertView.firstOtherButtonIndex){
            NSString *value =[alertView textFieldAtIndex:0].text;
            if (![value isEqualToString:@""]&& !([value intValue]>5) && !([value intValue]<1)) {
                //self.newStarRatingValue = [[alertView textFieldAtIndex:0].text intValue];
                [self performSelector:@selector(updateAverage:) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
            } else {
                [self showStarRatingValueAlert];
            }
        }
    } 
}

-(void) updateAverage:(NSString*)newValue {
    [self.summaryAveragedelegate updateStarRatingScoreAverage:self.ratingId withNewAverage:[newValue floatValue] withProductId:self.productId];
    
}


@end
