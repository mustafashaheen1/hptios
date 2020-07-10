//
//  ApplyToAllDialogView.m
//  Insights
//
//  Created by Vineet on 9/26/18.
//  Copyright © 2018 Yottamark. All rights reserved.
//

#import "ApplyToAllDialogView.h"
#import "ProductRatingViewController.h"
#import "UIPopoverListView.h"
#import "Result.h"
#import "SyncOverlayView.h"



@implementation ApplyToAllDialogView

SyncOverlayView *syncOverlayView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewModel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initViewModel];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    //
}


-(void) showPopupListView {
    
}

//Delegate Callback


-(void)initViewModel {
    self.viewModel = [[ApplyToAllViewModel alloc]init];
    [self.viewModel initRatings];
}



-(void)showPopupWithItems:(NSArray*)items withTitle:(NSString*)title withRatingId:(int)ratingId {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    CGFloat xWidth = win.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([items count] < 5) {
        int heightAfterCalculation = [items count] * 60.0f;
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.frame.size.height - yHeight)/2.0f;
    
    SpinnerPopup *poplistview = [[SpinnerPopup alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight) withItems:items withTitle:title withRatingId:(int)ratingId];
    poplistview.spinnerDelegate = self;
}


- (IBAction)cameraButtonTouched:(id)sender {
    
}

- (IBAction)okButtonTouched:(id)sender {
   

    Result *result = [self.viewModel validateRatings];
    if(!result.success){
         [[[UIAlertView alloc] initWithTitle:@"Error" message:result.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Finish Inspection?" message:@"Finishing the inspection will prevent further modifications."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Ok", nil];
        [alert setTag:1];
        [alert show];
    }
}

- (IBAction)cancelButtonTouched:(id)sender {
    [self removeFromSuperview];
}

//Alert View
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            
        }
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self finishInspection];
        }
    }
    
}

-(void) finishInspection {
    [self showLoadingScreenWithText:@"Saving..."];
    //return rating answers to parent screen
    [self.viewModel completeApplyToAll];
    [self dismissLoadingScreen];
    [self.applyToAllDelegate applyToAllSaved];
    [self removeFromSuperview];
}

-(void)showLoadingScreenWithText:(NSString*)message
{
    if(!message || [message length]==0)
        message = @"Loading....";
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    syncOverlayView.headingTitleLabel.text = message;
    [syncOverlayView showActivityView];
    [win addSubview:syncOverlayView];
}

-(void)dismissLoadingScreen
{
    [syncOverlayView dismissActivityView];
    [syncOverlayView removeFromSuperview];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewModel.ratings.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BaseTableViewCell *baseTableViewCell;
    NSArray *ratings = self.viewModel.ratings;
    if (ratings && [ratings count] > indexPath.row) {
        Rating *rating = [ratings objectAtIndex:indexPath.row];
        
        if (rating && [rating.type isEqualToString:STAR_RATING]) {
            
            StarRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kStarRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kStarRatingViewCellNIBFile owner:self options:nil];
                newCell = self.starRatingViewCell;
                self.starRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:TEXT_RATING]) {
            
            TextRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kTextRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kTextRatingViewCellNIBFile owner:self options:nil];
                newCell = self.textRatingViewCell;
                self.textRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:DATE_RATING]) {
            
            DateRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kDateRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kDateRatingViewCellNIBFile owner:self options:nil];
                newCell = self.dateRatingViewCell;
                self.dateRatingViewCell = nil;
            }
            UIWindow *win = [[UIApplication sharedApplication] keyWindow];
           // newCell.datePickerView.frame = CGRectMake(0, (baseTableViewCell.bounds.origin.y + 200), win.frame.size.width, 260.0);
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:NUMERIC_RATING]) {

            NumericRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kNumericRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kNumericRatingViewCellNIBFile owner:self options:nil];
                newCell = self.numericRatingViewCell;
                self.numericRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:PRICE_RATING]) {
            
            PriceRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kPriceRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kPriceRatingViewCellNIBFile owner:self options:nil];
                newCell = self.priceRatingViewCell;
                self.priceRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
            
        } else if (rating && [rating.type isEqualToString:COMBO_BOX_RATING]) {
            
            SelectButtonRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kSelectButtonRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kSelectButtonRatingViewCellNIBFile owner:self options:nil];
                newCell = self.selectButtonRatingViewCell;
                newCell.delegate = self;
                self.selectButtonRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        } else if (rating && [rating.type isEqualToString:BOOLEAN_RATING]) {
            
            BooleanRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kBooleanRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kBooleanRatingViewCellNIBFile owner:self options:nil];
                newCell = self.booleanRatingViewCell;
                self.booleanRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        } else if (rating && [rating.type isEqualToString:LABEL_RATING]) {
            
            LabelRatingViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:kLabelRatingViewCellReuseID];
            if (newCell == nil) {
                [[NSBundle mainBundle] loadNibNamed:kLabelRatingViewCellNIBFile owner:self options:nil];
                newCell = self.labelRatingViewCell;
                self.labelRatingViewCell = nil;
            }
            baseTableViewCell = (BaseTableViewCell*)newCell;
        }
        
        if (baseTableViewCell) {
            baseTableViewCell.myTableView = self.ratingsTableView;
           
            baseTableViewCell.rating = rating;
            
            baseTableViewCell.questionNumber = indexPath.row + 1;
            
            

            //TODO check if this is needed for all ratings
            //for days validation message
            if([baseTableViewCell.rating.type isEqualToString:DATE_RATING]){
                [baseTableViewCell refreshState];
            }
            
            return baseTableViewCell;
        }
        
    }
    
    UITableViewCell *emptyCell;
    emptyCell = [tableView dequeueReusableCellWithIdentifier:kEmptyTableCellIdentifier];
    if (emptyCell == nil) {
        emptyCell = [[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:kEmptyTableCellIdentifier];
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return emptyCell;
}

@end
