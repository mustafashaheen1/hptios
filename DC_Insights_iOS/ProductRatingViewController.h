//
//  ProductRatingViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/15/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
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
#import "DescriptionRatingViewCell.h"
#import "SelectButtonRatingViewCell.h"
#import "LocationRatingViewCell.h"
#import "FailedValidationView.h"
#import "Product.h"
#import "CurrentAudit.h"
#import "SyncOverlayView.h"


#define kProductRatingViewNIBName @"ProductRatingViewController"

@protocol ProductRatingViewControllerDelegate <NSObject>
@optional
- (void) proceedToNextGroup:(NSArray *) ratingsReponses withSuccess:(BOOL) success;
- (void) checkCountOfCases:(Rating *) currentRating withCount:(NSString*)count;
@end

@interface ProductRatingViewController : ParentNavigationViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FailedValidationViewProtocol, SelectButtonRatingCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *ratingsTableView;
@property (strong, nonatomic) NSArray *ratingsGlobal;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSMutableDictionary *ratingViewCells;
@property (strong, nonatomic) InputScanViewCell *inputScanViewCell;
@property (strong, nonatomic) SelectViewCell *selectViewCell;
@property (strong, nonatomic) CellBuilder *cellBuilder;
@property (strong, nonatomic) IBOutlet StarRatingViewCell *starRatingViewCell;
@property (strong, nonatomic) IBOutlet TextRatingViewCell *textRatingViewCell;
@property (strong, nonatomic) IBOutlet DateRatingViewCell *dateRatingViewCell;
@property (strong, nonatomic) IBOutlet NumericRatingViewCell *numericRatingViewCell;
@property (strong, nonatomic) IBOutlet PriceRatingViewCell *priceRatingViewCell;
@property (strong, nonatomic) IBOutlet BooleanRatingViewCell *booleanRatingViewCell;
@property (strong, nonatomic) IBOutlet SelectButtonRatingViewCell *selectButtonRatingViewCell;
@property (strong, nonatomic) IBOutlet LabelRatingViewCell *labelRatingViewCell;
@property (strong, nonatomic) IBOutlet LocationRatingViewCell *locationRatingViewCell;
@property (strong, nonatomic) IBOutlet DescriptionRatingViewCell *descriptionRatingViewCell;
@property (nonatomic, weak) id<ProductRatingViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *buttonNextStep;
@property (retain, nonatomic) NSString *parentView;
@property (retain, nonatomic) FailedValidationView *failedValidationView;
@property (strong, nonatomic) Product *productGlobal;
@property (strong, nonatomic) CurrentAudit *currentAuditGlobal;
@property (strong, nonatomic) Rating *ratingGlobal;
@property (nonatomic, assign) NSInteger currentPictureCount;
@property (strong, nonatomic) SyncOverlayView *syncOverlayView;
@property (strong, nonatomic) NSString *ratingNameForAlertView;
@property (strong, nonatomic) NSString *reasonForAlertView;
@property (nonatomic, strong) NSMutableArray *ratingsDynamic;
@property (nonatomic, assign) BOOL poSelectedFirst;
@property (nonatomic, assign) BOOL grnSelectedFirst;
@property (nonatomic, assign) BOOL supplierSelectedFirst;
//@property (nonatomic, strong) NSMutableArray *filteredOrderDataByContainer;
-(NSString*)getParentView;
- (IBAction)submitAnswersTouched:(id)sender;
- (IBAction)previousButton:(id)sender;
- (IBAction)doneButton:(id)sender;
- (void)tellOtherQuestionsToCloseKeyboard:(Rating*)currentRating;
- (NSInteger)verticalStartingPositionForRow:(NSInteger)rowNumber;
- (void) setOrderDataComboRatingValue:(NSString *) string withOrderDataKey:(NSString*)key;
- (void) checkCountOfCases:(Rating *) currentRating withCount:(NSString*)count;
//-(NSArray*)getOrderDataByContainer;
@end
