//
//  CellDefects.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/12/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defect.h"

@interface DefectsViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UISwitch *defectSwitch;
@property (strong, nonatomic) IBOutlet UIImageView *defectImage;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) Defect *defect;

- (void) refreshState;

@end
