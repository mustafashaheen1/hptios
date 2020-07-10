//
//  InspectionTableView.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/29/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InspectionTotalSummaryTableViewCell.h"
#import "Summary.h"
#import "InspectionDefectTableTableViewCell.h"
#import "SyncOverlayView.h"
#import "SavedAudit.h"
#import "UserNetworkActivityView.h"
#import "UserNetworkActivityViewProtocol.h"
#import "SCLAlertView.h"
#import "RowSectionButton.h"
#import "SKSTableView.h"

#define kInspectionSubTableViewCellReuseID @"InspectionSubTableViewCell"
#define kInspectionSubTableViewCellNIBFile @"InspectionSubTableViewCell"

//delegate to handle the samples details interactions
@protocol SummaryDetailsTableViewCellDelegate <NSObject>
-(void) modifyInspectionWithTag:(int)tag withSection:(int)section withAuditCount:(int)count;
- (void) recalculateSavedAuditsWithDatabase: (FMDatabase *) databaseLocal withEdit:(BOOL) edited;
-(void) refreshSavedAudits;
@property NSArray *productAudits;
@property Summary *summary;

@required
- (void) updateCountOfCasesAndReloadTableView;
@end


@interface SummaryDetailsTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,SummaryAveragesDelegate>

@property (strong, nonatomic) RowSectionButton *modifyInspectionButton;
@property (strong, nonatomic) RowSectionButton *changeStatusButton;
@property (strong, nonatomic) RowSectionButton *splitButton;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@property (strong, nonatomic) UITextField *textFieldCountOfCases;
@property (strong, nonatomic) UIButton *buttonEditableForCountOfCases;
@property (strong, nonatomic) SavedAudit *savedAudit;
@property (strong, nonatomic) Summary *summary;
@property (assign, nonatomic) int totalHeight;
@property (strong, nonatomic) NSMutableDictionary *heightDictForRatings;
@property (weak, nonatomic) SKSTableView *parentTableView;
@property (retain) id <SummaryDetailsTableViewCellDelegate> delegate;
@property (strong, nonatomic) Product *globalProduct;
@property (strong, nonatomic) UISwitch *switchview;
@property (assign, nonatomic) int productId;
@property (strong,nonatomic) NSMutableArray *inspectionSamples;

@property UILabel *productLabel;
@property UILabel *productInspectionStatus;

@property (strong, nonatomic) UITableView *subMenuTableView;

@property (nonatomic, assign) int starRatingToModify;
@property (nonatomic, assign) int newStarRatingValue;
@property (nonatomic, assign) int auditCountToModify;
@property (nonatomic, assign) int oldStarRatingValue;
@property (nonatomic, assign) int inspectionSampleCountToDelete;

-(void) initSamplesStructure;
//split group
@property (assign,nonatomic) BOOL updateAveragesTableView;
@property (nonatomic, assign) BOOL splitModeOn;
@property (nonatomic, assign) int splitCount;
//@property (nonatomic,assign) NSString* nesplitGroupId;

//pass back to summary screen
@property (assign, nonatomic) int summaryScreenRow;
@property (assign, nonatomic) int summaryScreenSection;

@end


