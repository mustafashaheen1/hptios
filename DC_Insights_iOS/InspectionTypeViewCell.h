//
//  CellInspectionType.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/6/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InspectionTypeViewCell : UITableViewCell
@property (weak) UITableView *parentTableView;
@property (nonatomic, copy) void(^tapHandler)(NSUInteger tag);
- (IBAction)cameraButtonClick:(id)sender;
- (IBAction)selectInspectType:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *selectInspectionButton;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UILabel *inspectionTypeLabel;

@end

