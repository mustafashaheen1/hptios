//
//  DescriptionRatingViewCell.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/29/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "ViewController.h"

#define kDescriptionRatingViewCellReuseID @"DescriptionRatingViewCell"
#define kDescriptionRatingViewCellNIBFile @"DescriptionRatingViewCell"
@interface DescriptionRatingViewCell : BaseTableViewCell <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextView *theAnswer;
@property (weak, nonatomic) IBOutlet UITableView *caseCodesTableView;
@property (nonatomic, strong) NSMutableArray *caseCodes;
@property (nonatomic, strong) NSMutableArray *quantities;
@property (nonatomic, assign) int globalTag;
@end

