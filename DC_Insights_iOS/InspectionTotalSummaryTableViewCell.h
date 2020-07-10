//
//  InspectionDefectSummaryTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/29/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Severity.h"

@interface InspectionTotalSummaryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *defectLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediumPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorPercentageLabel;
@property (strong, nonatomic) NSArray *allTotalsList;
@property (weak, nonatomic) IBOutlet UIView *line;

- (void) refreshState;

@end
