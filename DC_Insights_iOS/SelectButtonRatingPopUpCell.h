//
//  SelectButtonRatingPopUpCell.h
//  Insights
//
//  Created by Vineet Pareek on 22/10/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectButtonRatingPopUpCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIButton *flagButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (strong, atomic) NSString* message;
@property (strong, atomic) NSString* messageTitle;
@end
