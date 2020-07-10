//
//  DefectsViewController.h
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/13/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//
//  This is the defects view controller.  This will be used
//  in the "inspection info" and "product rating" views
//  to aid the inspector in deciding on a quality rating.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "RatingSelectSectionHeader.h"
#import "UIPopoverListView.h"
#import "SKSTableView.h"
#import "QualityManual.h"
#import "WebViewForDefectsViewController.h"
#import "DivideEntryView.h"
@protocol DefectRatingViewControllerDelegate <NSObject>
- (void) saveTheDefectsInTheRating:(NSArray *) defectsResponses;
@end

@interface DefectsViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate, SectionHeaderViewDelegate, UITextFieldDelegate, UIPopoverListViewDataSource, UIPopoverListViewDelegate, SKSTableViewDelegate>
@property (nonatomic) NSArray *defectsArray;
@property (nonatomic) NSArray *defectsArrayLocal;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *sectionInfoArray;
@property (nonatomic, strong) IBOutlet UIView *alertDefectEntryView;
@property (nonatomic, strong) IBOutlet UIView *percentageEntryView;
//@property (nonatomic, strong) IBOutlet UIView *divideEntryView;
@property (nonatomic, strong) IBOutlet UILabel *defectAlertLabel;
@property (nonatomic, strong) IBOutlet UIButton *okAlertButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelAlertButton;
//@property (nonatomic, strong) IBOutlet UIButton *selectSeverityAlertButton;
@property (nonatomic, strong) IBOutlet UITextField *percentageTextField;
//@property (nonatomic, strong) IBOutlet UITextField *leftDivideTextField;
//@property (nonatomic, strong) IBOutlet UITextField *rightDivideTextField;
@property (nonatomic, strong) UIView *transparentBlackBGView;
@property (nonatomic, strong) NSIndexPath *indexPathOpenedForAlertView;
@property (nonatomic, weak) IBOutlet SKSTableView *defectsTableView;
@property (retain, nonatomic) IBOutlet UIButton *buttonSave;
@property (nonatomic, retain) id<DefectRatingViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *defectViewCells;
@property (strong, nonatomic) NSString *severityButtonLabelText;
//@property (weak, nonatomic) IBOutlet UILabel *calculatedPercentageLabel;
@property (nonatomic, strong) QualityManual *qualityManual;
//@property (weak, nonatomic) IBOutlet UILabel *severityNameLabel;
@property (nonatomic, assign) int severityCount;
@property (strong, nonatomic) NSString *globalDefectValues;
@property (nonatomic, strong) NSMutableArray *divideEntryViews;
- (IBAction) cancelButtonTouched:(id)sender;
- (IBAction) okButtonTouched:(id)sender;
- (IBAction) saveButtonTouched:(id)sender;



@end
