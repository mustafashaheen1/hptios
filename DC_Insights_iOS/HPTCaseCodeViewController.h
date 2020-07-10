//
//  HPTCaseCodeViewController.h
//  Insights
//
//  Created by Mustafa Shaheen on 6/17/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "ParentNavigationViewController.h"
#import "StarRatingViewCell.h"
#import "InputScanViewCell.h"
#import "SelectViewCell.h"
#import "CellBuilder.h"
#import "BaseTableViewCell.h"
#import "StarRatingViewCell.h"
#import "TextRatingViewCell.h"
#import "DateRatingViewCell.h"
#import "NumericRatingViewCell.h"
#import "PriceRatingViewCell.h"
#import "BooleanRatingViewCell.h"
#import "LabelRatingViewCell.h"
#import "LocationRatingViewCell.h"
#import "DescriptionRatingViewCell.h"
#import "SelectButtonRatingViewCell.h"
#import "FailedValidationView.h"
#import "Product.h"
#import "SyncOverlayView.h"
#import "HPTCaseCodeModel.h"


#define kCaseCodeViewNIBName @"HPTCaseCodeViewController"
@interface HPTCaseCodeViewController : ParentNavigationViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, FailedValidationViewProtocol, SelectButtonRatingCellDelegate, LocationRatingCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *ratingsTableView;
@property (strong, nonatomic) NSArray *ratingsGlobal;
@property (strong, nonatomic) IBOutlet StarRatingViewCell *starRatingViewCell;
@property (strong, nonatomic) IBOutlet TextRatingViewCell *textRatingViewCell;
@property (strong, nonatomic) IBOutlet DescriptionRatingViewCell *descriptionRatingViewCell;
@property (strong, nonatomic) IBOutlet DateRatingViewCell *dateRatingViewCell;
@property (strong, nonatomic) IBOutlet NumericRatingViewCell *numericRatingViewCell;
@property (strong, nonatomic) IBOutlet PriceRatingViewCell *priceRatingViewCell;
@property (strong, nonatomic) IBOutlet BooleanRatingViewCell *booleanRatingViewCell;
@property (strong, nonatomic) IBOutlet SelectButtonRatingViewCell *selectButtonRatingViewCell;
@property (strong, nonatomic) IBOutlet LabelRatingViewCell *labelRatingViewCell;
@property (strong, nonatomic) IBOutlet LocationRatingViewCell *locationRatingViewCell;
@property (atomic, strong) HPTCaseCodeModel *viewModel;
@property (strong, nonatomic) NSString *ratingNameForAlertView;
@property (strong, nonatomic) NSString *reasonForAlertView;
@property (strong, nonatomic) NSString *sscc;
@property (strong, nonatomic) NSMutableDictionary *ratingViewCells;
@property (strong, nonatomic) NSMutableArray *caseCodeList;

- (NSInteger)verticalStartingPositionForRow:(NSInteger)rowNumber;
- (void)tellOtherQuestionsToCloseKeyboard:(Rating*)currentRating;
@end
