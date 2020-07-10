//
//  CECodeDetailsExapndedView.m
//  Insights
//
//  Created by Vineet Pareek on 19/10/2016.
//  Copyright © 2016 Yottamark. All rights reserved.
//

#import "CECodeDetailsExapndedView.h"
#import "Constants.h"

@implementation CECodeDetailsExapndedView

-(void) initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-10, self.frame.size.height-10) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    [self addSubview:self.tableView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initTableView];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"event attirbs are: %d", [self.event.attributes count]);
    return [self.event.attributes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CEEventAttribute *attribute = [self.event.attributes objectAtIndex:indexPath.row];
    double height = [attribute getHeightWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f] withFrameWidth:self.frame.size.width];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    [self addAttributeViewsToCell:cell atIndexPath:indexPath];
    
    return cell;
}
//returns view for a single attribute (name/value rows)
-(UITableViewCell*)addAttributeViewsToCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    UIView *nameLabelBackground = [[UIView alloc]initWithFrame:
                                   CGRectMake(0, 0, self.frame.size.width, CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT)];
    [nameLabelBackground setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:
                          CGRectMake(CE_EVENT_ATTRIBUTE_LEFT_MARGIN, 0, self.frame.size.width, CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT)];
    nameLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [cell addSubview:nameLabelBackground];
    [cell addSubview:nameLabel];
    
    double yPosition = CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT;
    CEEventAttribute *attribute = [self.event.attributes objectAtIndex:indexPath.row];
    nameLabel.text = attribute.name;
    
    //iterate through attiribute value array and render each element in separate row
    // if any value has a | pipe character then display the values in 2 columns
    for(NSString* attributeValue in attribute.value){
        int numberRows = 1;
        CGSize yourLabelSize = [attributeValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
        if(yourLabelSize.width > self.frame.size.width)
            numberRows = 2;
        
        UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(CE_EVENT_ATTRIBUTE_LEFT_MARGIN, yPosition, self.frame.size.width-CE_EVENT_ATTRIBUTE_RIGHT_MARGIN, CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT*numberRows)];
        
        //check if right column needed
        UILabel *rightColumnValueLabel = nil;
        NSString* rightColumnValue =[self getRightColumnContentForAttributeValue:attributeValue];
        if(rightColumnValue){
            NSString* leftColumnValue =[self getLeftColumnContentForAttributeValue:attributeValue];
            valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(CE_EVENT_ATTRIBUTE_LEFT_MARGIN, yPosition, self.frame.size.width/2, CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT*numberRows)];
            rightColumnValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(CE_EVENT_ATTRIBUTE_LEFT_MARGIN+self.frame.size.width/2, yPosition, self.frame.size.width/2-CE_EVENT_ATTRIBUTE_RIGHT_MARGIN, CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT*numberRows)];
            rightColumnValueLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
            rightColumnValueLabel.text = rightColumnValue;
            rightColumnValueLabel.numberOfLines = 0;
            rightColumnValueLabel.lineBreakMode = UILineBreakModeWordWrap;
            
            valueLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
            valueLabel.text = leftColumnValue;
            valueLabel.numberOfLines = 0;
            valueLabel.lineBreakMode = UILineBreakModeWordWrap;
            [cell addSubview:valueLabel];
            [cell addSubview:rightColumnValueLabel];
        }else{
            valueLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
            valueLabel.text = attributeValue;
            valueLabel.numberOfLines = 0;
            valueLabel.lineBreakMode = UILineBreakModeWordWrap;
            [cell addSubview:valueLabel];
        }
        
        yPosition+=CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT*numberRows;
    }
    return cell;
}

//
//-(double)getHeightForAttributeRow:(NSIndexPath *)indexPath{
//    CEEventAttribute *attribute = [self.event.attributes objectAtIndex:indexPath.row];
//    double yPosition = CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT;//for the name
//    for(NSString* attributeValue in attribute.value){
//        //CGSize expectedLabelSize = [attributeValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f]
//                                        //  constrainedToSize:maximumLabelSize
//                                       //       lineBreakMode:yourLabel.lineBreakMode];
//        CGSize yourLabelSize = [attributeValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
//        //NSLog(@"VINEET - labelsize width %f height %f ",yourLabelSize.width, yourLabelSize.height);
//        if(yourLabelSize.width > self.frame.size.width)
//            yPosition+=CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT;
//        
//        
//        yPosition+=CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT;
//    }
//    return yPosition;
//}

//if attribute value has "|" then render the value in 2 columns
-(NSString*)getRightColumnContentForAttributeValue:(NSString*)value{
    if(value && [value containsString:@"|"]){
        NSString* rightColumnText =  [[value componentsSeparatedByString:@"|"] objectAtIndex:1];
        return rightColumnText;
    }
    return nil;
}

-(NSString*)getLeftColumnContentForAttributeValue:(NSString*)value{
    if(value && [value containsString:@"|"]){
        NSString* rightColumnText =  [[value componentsSeparatedByString:@"|"] objectAtIndex:0];
        return rightColumnText;
    }
    return nil;
}
/*
-(int)calculateAge:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSDate *dateToday = [NSDate date];
    NSTimeInterval secondsBetween = [dateToday timeIntervalSinceDate:date];

    int numberOfDays = secondsBetween / 86400;
    return numberOfDays;
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
