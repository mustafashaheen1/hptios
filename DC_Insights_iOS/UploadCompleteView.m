//
//  UploadCompleteViewTableViewCell.m
//  Insights
//
//  Created by Vineet Pareek on 25/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//

#import "UploadCompleteView.h"
#import "SyncHistoryTableViewCell.h"

@implementation UploadCompleteView

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"UploadCompleteView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
//        self.frame = CGRectMake(20, 100, win.frame.size.width - 50, win.frame.size.height/3);
//        [self setBackgroundColor:[UIColor lightGrayColor]];
//        //[self buttonsSetup];
//        //UIWindow *win = [[UIApplication sharedApplication] keyWindow];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0,25.0,250.0,40.0)];
//        titleLabel.text = @"Successfully Submitted";
//        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(win.frame.size.width/2,(win.frame.size.height/3) + 105 + 35.0,25.0,25.0)];
//        closeButton.titleLabel.text = @"Close";
//        [closeButton setBackgroundImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
//        [closeButton addTarget:self
//                        action:@selector(closeButtonTouched)
//              forControlEvents:UIControlEventTouchUpInside];
//        
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10.0, 70, self.frame.size.width - 30, 1)];
//        line.backgroundColor = [UIColor blackColor];
//        self.subMenuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 105, win.frame.size.width - 50, win.frame.size.height/3) style:UITableViewStylePlain];
//        self.subMenuTableView.tag = 100;
//        self.subMenuTableView.delegate = self;
//        self.subMenuTableView.dataSource = self;
//        self.subMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        self.subMenuTableView.backgroundColor = [UIColor lightGrayColor];
//        
//        [self addSubview:titleLabel];
//        [self addSubview:line];
//
//        [self addSubview:self.subMenuTableView]; // add it cell
//                [self addSubview:closeButton];
//        
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 200.0)];
//        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//        {
//            //footerView.frame = CGRectMake(0.0, 0.0, 320.0, 50.0);
//        }
//        //[footerView addSubview:self.modifyInspectionButton];
//        //[footerView addSubview:self.changeStatusButton];
//        self.subMenuTableView.tableFooterView = footerView;
//        
//    }
//    return self;
//}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
- (IBAction)OkButtonTouched:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)Dismiss:(id)sender {
     [self removeFromSuperview];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *cellID = [NSString stringWithFormat:@"cellID %d", indexPath.row];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//    //if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
//    }
//    cell.detailTextLabel.textColor = [UIColor blackColor];
//    cell.accessoryView = nil;
    
    SyncHistoryTableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:@"SyncHistoryTableViewCell"];
    if (newCell == nil) {
        newCell = [[NSBundle mainBundle] loadNibNamed:@"SyncHistoryTableViewCell" owner:self options:nil][0];
    }
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            newCell.auditsNumberLabel.text = @"Date";
            newCell.auditsCountLabel.text = @"# of Cases";
            newCell.imagesCountLabel.text = @"Ranch ID";
            newCell.statusLabel.text = @"Variety";
            newCell.statusLabel.textColor = [UIColor blackColor];
        } else {
            CompletedScanout *completedScanout = [self.uploadedScanouts objectAtIndex:indexPath.row];
            newCell.auditsNumberLabel.text = completedScanout.date;
            newCell.auditsCountLabel.text = [NSString stringWithFormat:@"%d", completedScanout.countOfCases];
            newCell.imagesCountLabel.text = completedScanout.ratingArray[0].value;
            newCell.statusLabel.text = completedScanout.ratingArray[1].value;
            newCell.statusLabel.textColor = [UIColor redColor];
        }
    }
    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.uploadedScanouts count];
}

@end
