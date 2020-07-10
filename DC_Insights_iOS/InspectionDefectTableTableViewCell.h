//
//  InspectionDefectTableTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 5/11/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InspectionDefectTableViewCell.h"
#import "Defect.h"
//#import "SummaryDetailsTableViewCell.h"


//delegate to handle the summary average interactions
@protocol SummaryAveragesDelegate <NSObject>
-(void) updateStarRatingScoreAverage:(int)ratingId withNewAverage:(int)newAverage withProductId:(int)productId;
@end

@interface InspectionDefectTableTableViewCell : UITableViewCell<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *allDefectsList;
@property (strong, nonatomic) IBOutlet InspectionDefectTableViewCell *inspectionDefectTableViewCell;
@property (strong, nonatomic) NSString *ratingName;
@property (strong, nonatomic) NSString *ratingValue;
@property (assign, nonatomic) int ratingId;
@property (assign, nonatomic) int productId;
@property (retain) id <SummaryAveragesDelegate> summaryAveragedelegate;
@property (strong, nonatomic) UITableView *subMenuTableView;
//@property (retain) id <InspectionDefectTableTableViewCellDelegate> summaryAveragedelegate;
@end
