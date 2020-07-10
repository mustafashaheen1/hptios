//
//  RatingSelectSectionHeader.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/8/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defect.h"
#import "SectionHeaderView.h"

@interface RatingSelectSectionHeader : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *severityLabel;
@property (nonatomic, strong) IBOutlet UIButton *checkMarkButton;
@property (nonatomic, strong) UIButton *collapseButton;
@property (nonatomic, strong) IBOutlet UIImageView *collapseButtonImageView;
@property (nonatomic, weak) IBOutlet id <SectionHeaderViewDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton *defectValuesButton;
@property (nonatomic, strong) IBOutlet UILabel *defectValuesLabel;
@property (nonatomic, assign) BOOL hideData;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *coverageType;
//@property (nonatomic, assign) float inputNumerator;
//@property (nonatomic, assign) float inputDenominator;
//@property (nonatomic, assign) float inputOrCalculatedPercentage;
//@property (nonatomic, strong) NSString *severityName;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, strong) Defect *defect;
@property (nonatomic, strong) NSMutableArray *globalSeverities;
@property (nonatomic) NSInteger section;

/**
 * The boolean value showing the receiver is expandable or not. The default value of this property is NO.
 */
@property (nonatomic, assign, getter = isExpandable) BOOL expandable;

/**
 * The boolean value showing the receiver is expanded or not. The default value of this property is NO.
 */
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;

/**
 * Adds an indicator view into the receiver when the relevant cell is expanded.
 */
- (void)addIndicatorView;

/**
 * Removes the indicator view from the receiver when the relevant cell is collapsed.
 */
- (void)removeIndicatorView;

/**
 * Returns a boolean value showing if the receiver contains an indicator view or not.
 *
 *  @return The boolean value for the indicator view.
 */
- (BOOL)containsIndicatorView;


- (void)toggleOpenWithUserAction:(BOOL)userAction;
- (void)toggleCheckMarkOpenWithUserAction:(BOOL)userAction;
- (IBAction)toggleCheckMark:(id)sender;
- (IBAction)defectValuesButtonTouched:(id)sender;

@end

#pragma mark -

/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
//@protocol SectionHeaderViewDelegate <NSObject>
//
//@optional
//- (void)sectionHeaderView:(RatingSelectSectionHeader *)sectionHeaderView sectionOpened:(NSInteger)section;
//- (void)sectionHeaderView:(RatingSelectSectionHeader *)sectionHeaderView sectionClosed:(NSInteger)section;
//- (void)sectionHeaderView:(RatingSelectSectionHeader *)sectionHeaderView alertViewOpened:(NSIndexPath *)indexPath;
//- (void)sectionHeaderView:(RatingSelectSectionHeader *)sectionHeaderView alertViewClosed:(NSIndexPath *)indexPath;
//
//@end
