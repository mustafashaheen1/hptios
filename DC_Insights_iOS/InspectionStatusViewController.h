//
//  ViewController.h
//  CollapseClick
//
//  Created by Ben Gordon on 2/28/13.
//  Copyright (c) 2013 Ben Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "SKSTableView.h"
#import "UIPopoverListView.h"
#import "Summary.h"
#import "SyncOverlayView.h"
#import "InspectionSubTableViewCell.h"
#import "RowSectionButton.h"
#import "SummaryDetailsTableViewCell.h"
#import "CollaborativeInspection.h"
#import "InspectionMinimums.h"
#import "RowSectionButton.h"
#import "InspectionStatus.h"
@interface InspectionStatusViewController : ParentNavigationViewController <UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate, SKSTableViewDelegate, UIPopoverListViewDelegate, UIPopoverListViewDataSource,UIAlertViewDelegate, InspectionSubTableViewCellDelegate,SummaryDetailsTableViewCellDelegate> {
}

@property (nonatomic, strong) SKSTableView *table;
@property (nonatomic, strong) NSMutableArray *productAudits;
@property (nonatomic, strong) NSMutableArray *productAuditsCacheForAutoComplete;
@property (nonatomic, strong) NSArray *statusValues;
@property (nonatomic, strong) IBOutlet UIButton *productSelectButton;
@property (nonatomic, strong) Summary *summaryGlobal;
@property (nonatomic, strong) NSMutableDictionary *summaryDictionary;
@property (nonatomic, strong) NSMutableDictionary *summaryDictionaryForChangeStatus;
@property (nonatomic, assign) int currentGroupId;
@property (nonatomic, assign) int currentProductId;
@property (nonatomic, strong) SyncOverlayView *syncOverlayView;
@property (nonatomic, strong) UILabel *productNameLabel;
@property (nonatomic, strong) UILabel *countOfCasesLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) NSMutableDictionary *keepTrackOfOpenedRows;
@property (nonatomic, assign) BOOL navigationButtonsTapped;
@property (nonatomic, assign) BOOL hasDefects;
@property (nonatomic, strong) Product *globalProduct;
@property (nonatomic, strong) InspectionStatus *globalInspectionStatus;
@property (nonatomic, strong) RowSectionButton *btnToModify;
@property (nonatomic, strong) NSArray *distinctSupplierNames;
@property (nonatomic, strong) NSMutableDictionary *inspectionMinimums;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSMutableArray *allFlaggedProductMessages;
@property (nonatomic, assign) int starRatingToModify;
@property (nonatomic, assign) int scoreableIndex;
@property (nonatomic, assign) int nonScoreableIndex;
@property (nonatomic, assign) int newStarRatingValue;
@property (nonatomic, assign) int auditCountToModify;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic, strong) RowSectionButton *flaggedProductButton;
@property (nonatomic, assign) BOOL globalNotification;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) NSString *globalAuditMasterId;
@property (nonatomic, strong) NSString* currentSplitGroupId; //current split group Id
@property (nonatomic, strong) NSString *previousInspectionStatus;
@property (nonatomic, assign) int productId;
/*!
 *  Product Select Button takes the user to the ProductSelectAutoCompleteViewController
 *
 *  @param sender self
 */
- (IBAction)productSelectButtonTouched:(id)sender;
- (void) modifyInspectionWithTag: (int) tag withSection:(int) section withAuditCount:(int)count;

/*!
 *  Recalculates saved audits whenever there is a change in the 
 *  1) Count of Cases.
 *  2) Inspection samples count.
 *  3) Inspection status.
 *
 *  @param databaseLocal Instance of the database
 */
- (void) recalculateSavedAuditsWithDatabase: (FMDatabase *) databaseLocal;
- (void) updateNotificationInDB:(BOOL) notification withGroupId:(NSString *) groupId withAuditMasterID:(NSString *)auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal withSplitGroupId: (NSString *) splitGroupId withInspectionStatus: (NSString *) inspectionStatus;
- (int) getUserEnteredChangedFromDB:(NSString *) groupId withAuditMasterId:(NSString *) auditMasterId withProductId: (NSString *) productId withProductGroupId: (NSString *) productGroupId withDatabase: (FMDatabase *) databaseLocal;
@end
