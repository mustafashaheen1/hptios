//
//  ApplyToAllDialogView.h
//  Insights
//
//  Created by Vineet on 9/26/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "StarRatingViewCell.h"
#import "TextRatingViewCell.h"
#import "DateRatingViewCell.h"
#import "NumericRatingViewCell.h"
#import "PriceRatingViewCell.h"
#import "BooleanRatingViewCell.h"
#import "LabelRatingViewCell.h"
#import "SelectButtonRatingViewCell.h"
#import "ApplyToAllViewModel.h"
#import "SpinnerPopup.h"

@protocol ApplyToAllDialogDelegate <NSObject>

-(void)applyToAllSaved;

@end

@interface ApplyToAllDialogView : UIView<UIImagePickerControllerDelegate,UIPopoverListViewDelegate, UIPopoverListViewDataSource,SpinnerPopupDelegate,UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *inspectionStatusButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sampleCountToggle;
@property (weak, nonatomic) IBOutlet UITableView *ratingsTableView;

@property (weak, nonatomic) IBOutlet UITextField *sampleCountField;

@property (retain) id <ApplyToAllDialogDelegate> applyToAllDelegate;
@property (strong, nonatomic) IBOutlet StarRatingViewCell *starRatingViewCell;
@property (strong, nonatomic) IBOutlet TextRatingViewCell *textRatingViewCell;
@property (strong, nonatomic) IBOutlet DateRatingViewCell *dateRatingViewCell;
@property (strong, nonatomic) IBOutlet NumericRatingViewCell *numericRatingViewCell;
@property (strong, nonatomic) IBOutlet PriceRatingViewCell *priceRatingViewCell;
@property (strong, nonatomic) IBOutlet BooleanRatingViewCell *booleanRatingViewCell;
@property (strong, nonatomic) IBOutlet SelectButtonRatingViewCell *selectButtonRatingViewCell;
@property (strong, nonatomic) IBOutlet LabelRatingViewCell *labelRatingViewCell;

@property (strong, nonatomic) ApplyToAllViewModel *viewModel;
@property (strong, nonatomic) NSMutableDictionary *ratingViewCells;



@end


