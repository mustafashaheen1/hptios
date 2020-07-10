//
//  CaseCodesTableViewCell.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/30/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCaseCodeViewCellReuseID @"CaseCodeViewCell"
#define kCaseCodeViewCellNIBFile @"CaseCodeViewCell"
@interface CaseCodesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *code;
@property (weak, nonatomic) IBOutlet UIButton *quantity;
@property (weak, nonatomic) IBOutlet UIButton *remove;

@end


