//
//  SyncHistoryTableViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 6/10/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncHistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *auditsNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *auditsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *imagesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@end
