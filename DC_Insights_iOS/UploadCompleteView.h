//
//  UploadCompleteViewTableViewCell.h
//  Insights
//
//  Created by Vineet Pareek on 25/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompletedScanout.h"
#import "SyncHistoryTableViewCell.h"

@interface UploadCompleteView : UIView<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong,nonatomic) NSMutableArray<CompletedScanout*> *uploadedScanouts;
//@property (strong, nonatomic) UITableView *subMenuTableView;
@property (weak, nonatomic) IBOutlet SyncHistoryTableViewCell *syncHistoryTableViewCell;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UITableView *subMenuTableView;

@end
