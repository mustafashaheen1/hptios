//
//  InspectionTableView.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/29/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "SummaryDetailsTableViewCell.h"
#import "Inspection.h"
#import "ImageArray.h"

#define cellHeightForDefect 84

@interface SummaryInspectionSamples : NSObject
@property int sampleCount;
@property Rating *rating;
@property Defect *defect;
@property int type;
@property BOOL needSplit;
@end

@implementation SummaryInspectionSamples
@end

@implementation SummaryDetailsTableViewCell

enum{
    TYPE_PRODUCT, TYPE_RATING, TYPE_DEFECT, TYPE_LINE
};

@synthesize modifyInspectionButton;
@synthesize changeStatusButton;
@synthesize buttonEditableForCountOfCases;
@synthesize switchview;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        self.frame = CGRectMake(0, -20, win.frame.size.width, win.frame.size.height);
        [self setBackgroundColor:[UIColor whiteColor]];
        //[self buttonsSetup];
        //UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0,25.0,250.0,40.0)];
        titleLabel.text = @"Summary Details";
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0,35.0,25.0,25.0)];
        closeButton.titleLabel.text = @"Close";
        [closeButton setBackgroundImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self
                   action:@selector(closeButtonTouched)
         forControlEvents:UIControlEventTouchUpInside];
        //split button
//        UIButton *splitButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0,35.0,25.0,25.0)];
//        splitButton.titleLabel.text = @"Split";
//        //[closeButton setBackgroundImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
//        [splitButton addTarget:self
//                        action:@selector(closeButtonTouched)
//              forControlEvents:UIControlEventTouchUpInside];
        
        self.splitButton = [RowSectionButton buttonWithType:UIButtonTypeCustom];
        self.splitButton.frame = CGRectMake(220.0,35.0,75.0,25.0);
        self.splitButton.backgroundColor = [UIColor grayColor];
        self.splitButton.layer.cornerRadius = 5.0;
        self.splitButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [self.splitButton setTitle:@"Split" forState:UIControlStateNormal];
        self.splitButton.titleLabel.textColor = [UIColor whiteColor];
        [self.splitButton addTarget:self
                        action:@selector(splitButtonTouched)
              forControlEvents:UIControlEventTouchUpInside];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10.0, 70, self.frame.size.width - 30, 1)];
        line.backgroundColor = [UIColor blackColor];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.productLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,75.0,300.0,20.0)];
            self.productLabel.text = @"Product Name";
            self.productLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
            self.productLabel.textAlignment = NSTextAlignmentLeft;
            self.productLabel.adjustsFontSizeToFitWidth = NO;

        }else{
            self.productLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,75.0,200.0,20.0)];
            self.productLabel.text = @"Product Name";
            self.productLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
            self.productLabel.textAlignment = NSTextAlignmentLeft;
            self.productLabel.adjustsFontSizeToFitWidth = NO;
            self.productLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.productInspectionStatus = [[UILabel alloc] initWithFrame:CGRectMake(win.frame.size.width-200.0,75.0,170.0,20.0)];
            self.productInspectionStatus.text = @"Inspection";
            self.productInspectionStatus.font = [UIFont fontWithName:@"Helvetica" size:15.0];
            self.productInspectionStatus.textAlignment = NSTextAlignmentRight;
        }else{
            self.productInspectionStatus = [[UILabel alloc] initWithFrame:CGRectMake(win.frame.size.width-170.0,75.0,150.0,20.0)];
            self.productInspectionStatus.text = @"Inspection";
            self.productInspectionStatus.font = [UIFont fontWithName:@"Helvetica" size:12.0];
            self.productInspectionStatus.textAlignment = NSTextAlignmentRight;
        }
        
        self.subMenuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 105, win.frame.size.width-10, win.frame.size.height-10) style:UITableViewStylePlain];
        self.subMenuTableView.tag = 100;
        self.subMenuTableView.delegate = self;
        self.subMenuTableView.dataSource = self;
        self.subMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //subMenuTableView.backgroundColor = [UIColor lightGrayColor];
        
        [self addSubview:titleLabel];
        [self addSubview:self.splitButton];
        [self addSubview:line];
        [self addSubview:closeButton];
        [self addSubview:self.productLabel];
        [self addSubview:self.productInspectionStatus];
        [self addSubview:self.subMenuTableView]; // add it cell
        //[self insertSubview:subMenuTableView belowSubview:someLabel];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 200.0)];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //footerView.frame = CGRectMake(0.0, 0.0, 320.0, 50.0);
        }
        //[footerView addSubview:self.modifyInspectionButton];
        //[footerView addSubview:self.changeStatusButton];
        self.subMenuTableView.tableFooterView = footerView;
        
    }
    return self;
}

-(void) initSamplesStructure {
    //create flat structure for table view
    NSMutableArray *inspectionSamplesArray = [[NSMutableArray alloc]init];
    int i=0;
    int y=0;
    Product *currentProduct = [[Product alloc]init];
    for(Product *product in self.summary.inspectionSamples){
        i++;
        currentProduct = product;
        SummaryInspectionSamples *sample = [[SummaryInspectionSamples alloc]init];
        sample.sampleCount = i;
        sample.type = TYPE_PRODUCT;
        [inspectionSamplesArray insertObject:sample atIndex:y++];
        for(Rating *rating in currentProduct.ratingsFromUI){
            SummaryInspectionSamples *sample = [[SummaryInspectionSamples alloc]init];
            sample.sampleCount = i;
            sample.rating = [[Rating alloc]init];
            sample.rating.name = rating.name;
            sample.rating.ratingID = rating.ratingID;
            if(rating.value)
            sample.rating.value = rating.value;
            sample.type = TYPE_RATING;
            //NSLog(@"rating name is: %@",sample.rating.name);
            //NSLog(@"rating value is: %@",sample.rating.value);
            [inspectionSamplesArray insertObject:sample atIndex:y++];
            for(Defect *defect in rating.defects){
                SummaryInspectionSamples *sample = [[SummaryInspectionSamples alloc]init];
                sample.sampleCount = i;
                sample.defect = [[Defect alloc]init];
                sample.defect.severities = [defect.severities copy];
                sample.defect.name = defect.name;
                sample.type = TYPE_DEFECT;
                [inspectionSamplesArray insertObject:sample atIndex:y++];
            }
        }
        SummaryInspectionSamples *divider = [[SummaryInspectionSamples alloc]init];
        divider.sampleCount = i;
        divider.type = TYPE_LINE;
        divider.needSplit = NO;
        [inspectionSamplesArray insertObject:divider atIndex:y++];
    }
   // [inspectionSamplesArray addObject:[NSString stringWithFormat:@"Score and Defect Totals"]];
    self.inspectionSamples = inspectionSamplesArray;
    
    
    // init the product name and insp status
    self.productLabel.text =  self.savedAudit.productName; //@"RUSEELLL POTATOES(42342322423)";
    self.productInspectionStatus.text = [NSString stringWithFormat:@"%@", self.savedAudit.inspectionStatus];
    
    if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) {
        self.productInspectionStatus.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];; //[UIColor greenColor];
    } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) {
        self.productInspectionStatus.textColor = [UIColor redColor];
    } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
        self.productInspectionStatus.textColor = [UIColor orangeColor];
    } else {
        self.productInspectionStatus.textColor = [UIColor greenColor];
    }
}

-(void)closeButtonTouched {
    [self removeFromSuperview];
    
   /* [UIView transitionWithView:self.window
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromRight //any animation
                    animations:^ {  [self removeFromSuperview]; }
                    completion:nil];*/
}

- (void) buttonsSetup {
    self.modifyInspectionButton = [RowSectionButton buttonWithType:UIButtonTypeCustom];
    self.modifyInspectionButton.frame = CGRectMake(15, 3, 130, 40);
    self.modifyInspectionButton.backgroundColor = [UIColor grayColor];
    self.modifyInspectionButton.layer.cornerRadius = 5.0;
    self.modifyInspectionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [self.modifyInspectionButton setTitle:@"Modify Inspection" forState:UIControlStateNormal];
    self.modifyInspectionButton.titleLabel.textColor = [UIColor whiteColor];
    
    self.changeStatusButton = [RowSectionButton buttonWithType:UIButtonTypeCustom];
    self.changeStatusButton.frame = CGRectMake(170, 3, 130, 40);
    self.changeStatusButton.backgroundColor = [UIColor grayColor];
    self.changeStatusButton.layer.cornerRadius = 5.0;
    self.changeStatusButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [self.changeStatusButton setTitle:@"Change Status" forState:UIControlStateNormal];
    self.changeStatusButton.titleLabel.textColor = [UIColor whiteColor];
    [self.changeStatusButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.changeStatusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self.changeStatusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.heightDictForRatings = [[NSMutableDictionary alloc] init];
    [self calculateHeightForTheInspectionDefectCell2];
   // UITableView *subMenuTableView =(UITableView *) [self viewWithTag:100];
    //[subMenuTableView reloadData];
   // subMenuTableView.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5,    self.bounds.size.height-5);//set the frames for tableview
    //self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 20.0, 0.0);
}

- (void) calculateHeightForTheInspectionDefectCell {
    self.totalHeight = 0;
    int heightForRating = 0;
    BOOL defectPresent = NO;
    for(Rating *aRating in self.summary.allRatingsList) {
        heightForRating = 0;
        defectPresent = NO;
        self.totalHeight = self.totalHeight + 20;
        heightForRating = heightForRating + 20;
        for(Defect *aDefect in aRating.defects) {
            defectPresent = YES;
            for(Severity *aSeverity in aDefect.severities) {
                if (aSeverity.inputOrCalculatedPercentage != 0) {
                    self.totalHeight = self.totalHeight + cellHeightForDefect;
                    heightForRating = heightForRating + cellHeightForDefect;
                    break;
                }
            }
        }
        if (!defectPresent) {
            self.totalHeight = self.totalHeight - 20;
            heightForRating = heightForRating - cellHeightForDefect;
        }
        [self.heightDictForRatings setObject:[NSString stringWithFormat:@"%d", heightForRating] forKey:[NSString stringWithFormat:@"%d", aRating.ratingID]];
    }
}

- (void) calculateHeightForTheInspectionDefectCell2 {
    for(Rating *aRating in self.summary.allRatingsList) {
        int heightForRating = 10;
        heightForRating = heightForRating + 20;
        for(Defect *aDefect in aRating.defects) {
            heightForRating = heightForRating + 15; //24;
            /*for(Severity *aSeverity in aDefect.severities) {
                //heightForRating = heightForRating + 24; //since moving defects and sev to same line in new summary screen
            }*/
        }
        [self.heightDictForRatings setObject:[NSString stringWithFormat:@"%d", heightForRating] forKey:[NSString stringWithFormat:@"%d", aRating.ratingID]];
    }
}

//manage datasource and  delegate for submenu tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    int numberOfSections = 7;
//    if (sendNotificationOptionEnabled) {
//        numberOfSections = 8;
//    }
//    return numberOfSections;
    return 7;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        //return 2; //1; //for the text "Score and Defect Totals"
//        int something =[self.summary.inspectionSamples count] * [self.summary.allRatingsList count];
//        return 5;
       // return 3; //[self.summary.allRatingsList count];
        return [self.inspectionSamples count];
    } else if (section == 3) {
        return 1;
    } else if (section == 4) {
      return [self.summary.allRatingsList count];
    } else if (section == 5) {
        return 1;
    } else if (section == 6) {
        return 1;
    } else if (section == 7) {
        return 1;
    }
    return 0;
}

- (void) buttonCountOfCasesSetup {
    if (!self.buttonEditableForCountOfCases) {
        self.buttonEditableForCountOfCases = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    self.buttonEditableForCountOfCases.backgroundColor = [UIColor colorWithRed:159/255.0 green:154/255.0 blue:143/255.0 alpha:1.0];
    self.buttonEditableForCountOfCases.frame = CGRectMake(270, 8, 40, 20);
    self.buttonEditableForCountOfCases.layer.borderColor = [[UIColor blackColor] CGColor];
    self.buttonEditableForCountOfCases.layer.borderWidth = 1.0;
    self.buttonEditableForCountOfCases.layer.cornerRadius = 1.0;
    [self.buttonEditableForCountOfCases setTitle:[NSString stringWithFormat:@"%d", self.summary.totalCountOfCases] forState:UIControlStateNormal];
    self.buttonEditableForCountOfCases.titleLabel.textColor = [UIColor whiteColor];
    self.buttonEditableForCountOfCases.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self.buttonEditableForCountOfCases addTarget:self action:@selector(changeCountOfCases:) forControlEvents:UIControlEventTouchUpInside];
}

-(NSMutableAttributedString*)getUnderlineTextForString:(NSString*)string {
    NSMutableAttributedString *underlineText = [[NSMutableAttributedString alloc] initWithString:string];
    [underlineText addAttribute:NSUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:2]
                          range:(NSRange){0,[string length]}];
    [underlineText addAttribute:NSUnderlineColorAttributeName
                          value:[UIColor blueColor]
                          range:(NSRange){0,[string length]}];
    return underlineText;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"cellID %d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    //if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.accessoryView = nil;
    if (indexPath.section == 0) {

    } else if (indexPath.section == 1) {

    } else if (indexPath.section == 2) {
        SummaryInspectionSamples *value = [self.inspectionSamples objectAtIndex:indexPath.row];
        if(value.type == TYPE_PRODUCT){
            cell.textLabel.text = [NSString stringWithFormat:@"Inspection Sample %d", value.sampleCount];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:15.0];
            
            //show delete button
            //if(!aggregateSamplesMode){
            UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(180.0,0.0,25.0,25.0)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                closeButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0,0.0,25.0,25.0)];
            }
            closeButton.tag = value.sampleCount;
            closeButton.titleLabel.text = @"delete";
            [closeButton setBackgroundImage:[UIImage imageNamed:@"ic_discard_gray.png"] forState:UIControlStateNormal];
            [closeButton addTarget:self
                            action:@selector(showDeleteSampleAlert:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:closeButton];
            //}
            
            UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(230.0,0.0,25.0,25.0)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                editButton = [[UIButton alloc] initWithFrame:CGRectMake(320.0,0.0,25.0,25.0)];
            }
            editButton.tag = value.sampleCount;
            editButton.titleLabel.text = @"edit";
            [editButton setBackgroundImage:[UIImage imageNamed:@"ic_edit.png"] forState:UIControlStateNormal];
            [editButton addTarget:self
                            action:@selector(editSample:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:editButton];
            UIButton *splitButton = [[UIButton alloc] initWithFrame:CGRectMake(280.0,0.0,25.0,25.0)];
            splitButton.tag = indexPath.row;
            splitButton.titleLabel.text = @"split";
            if(value.needSplit) {
                [splitButton setBackgroundImage:[UIImage imageNamed:@"ic_split_down.png"] forState:UIControlStateNormal];
            }
            else {
                [splitButton setBackgroundImage:[UIImage imageNamed:@"ic_split_up.png"] forState:UIControlStateNormal];
            }
            [splitButton addTarget:self
                           action:@selector(addToSplit:)
                 forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:splitButton];
            
        } else if(value.type == TYPE_RATING){
            cell.textLabel.text = [NSString stringWithFormat:@"%@",value.rating.name];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value.rating.value];
             cell.detailTextLabel.attributedText = [self getUnderlineTextForString:[NSString stringWithFormat:@"%@", value.rating.value]];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
            //if(value.rating.value!=nil)
            //NSLog(@"RAting Value is: %@", value.rating.value);
        }else if(value.type == TYPE_DEFECT){
            Defect *defect = value.defect;
            Severity *severity = [defect.severities objectAtIndex:0];
            cell.textLabel.text = [NSString stringWithFormat:@"  %@ - %@",defect.name, severity.name];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
            if(severity.inputOrCalculatedPercentage>0)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f%%", severity.inputOrCalculatedPercentage];
            else
                cell.detailTextLabel.text = @"";
            cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        }else if(value.type == TYPE_LINE){
//            cell.textLabel.text = [NSString stringWithFormat:@"  %@",((NSString*)value)];
//            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, cell.contentView.bounds.size.width, 1)];
            lineView.backgroundColor = [UIColor blackColor];
            lineView.autoresizingMask = 0x3f;
            [cell.contentView addSubview:lineView];
        }
        //NSLog(@"TEXT IS: %@",cell.textLabel.text);
        return cell;
        
    } else if (indexPath.section == 3) {
       cell.textLabel.text = @"Score And Defect Totals";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:15.0];
    } else if (indexPath.section == 4) {
        InspectionDefectTableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if(cell == nil)
        {
            cell = [[InspectionDefectTableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        Rating *rating = [self.summary.allRatingsList objectAtIndex:indexPath.row];
        cell.ratingName = rating.name;
        cell.ratingValue = rating.value;
        cell.allDefectsList = rating.defects;
        cell.ratingId = rating.ratingID;
        cell.productId = self.productId;
        cell.summaryAveragedelegate = self;
       // if(self.updateAveragesTableView) {
            [cell.subMenuTableView reloadData];
            //self.updateAveragesTableView = NO;
        //}
        return  cell;
    } else if (indexPath.section == 5) {
        cell.textLabel.text = @"Defects Grand Total";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", self.summary.grandTotal];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 29, self.frame.size.width - 30, 1)];
        line.backgroundColor = [UIColor blackColor];
        [cell.contentView addSubview:line];
    } else if (indexPath.section == 6) {
        cell.textLabel.text = @"Inspection Status";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) {
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];
        } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) {
            cell.detailTextLabel.textColor = [UIColor redColor];
        } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor blueColor];
        }
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.summary.inspectionStatus];
    } else if (indexPath.section == 7) {
        cell.textLabel.text = @"Send notification";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        self.switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchview.on = NO;
        if (self.summary.sendNotification) {
            switchview.on = YES;
        }
        [switchview addTarget:self action:@selector(updateSwitchAtIndexPath) forControlEvents:UIControlEventTouchUpInside];
        cell.detailTextLabel.text = @"";
        cell.accessoryView = switchview;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.switchview = nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSLog(@"insepction samples touched");
        //if ([[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
//        if (aggregateSamplesMode) {
//            [self showAlertViewForInspectionSamples];
//        }
    } else if (indexPath.section == 2) {
        SummaryInspectionSamples *value =[self.inspectionSamples objectAtIndex:indexPath.row];
        if(value.type == TYPE_RATING){
            //[self updateStarRatingScore:value.rating.ratingID];
            self.starRatingToModify = value.rating.ratingID;
            self.newStarRatingValue = 0;
            self.auditCountToModify = value.sampleCount;
            self.oldStarRatingValue = [value.rating.value intValue];
            [self showStarRatingValueAlert];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns 60.0 points for all subrows.
    if (indexPath.section == 5 || indexPath.section == 6) {
        return 30;
    }else if(indexPath.section == 2){
        //Rating *aRating = [self.summary.allRatingsList objectAtIndex:indexPath.row];
       // int height = [[self.heightDictForRatings objectForKey:[NSString stringWithFormat:@"%d", aRating.ratingID]] integerValue];
        SummaryInspectionSamples *value =[self.inspectionSamples objectAtIndex:indexPath.row];
        if(value.type == TYPE_PRODUCT)
        return 30; //[self.inspectionSamples count]*4;
        else
            return 20;
    }else if (indexPath.section == 3) {
        return 30 ;//30.0f;
    } else if (indexPath.section == 4) {
        Rating *aRating = [self.summary.allRatingsList objectAtIndex:indexPath.row];
        int height = [[self.heightDictForRatings objectForKey:[NSString stringWithFormat:@"%d", aRating.ratingID]] integerValue];
        return height;
    } else if (indexPath.section == 7) {
        return 133.0f;
    } else {
        return 0;
    }
}

- (void)updateSwitchAtIndexPath {
    BOOL switchNature = NO;
    if (!self.summary.sendNotification) {
        switchNature = YES;
        self.summary.sendNotification = YES;
    } else {
        switchNature = NO;
        self.summary.sendNotification = NO;
    }
    
    UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
    [activityView setCustomMessage:@"Updating.."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [activityView show:self withOperation:nil showCancel:NO];
    }
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        [self.summary updateNotificationInDB:switchNature withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withProductGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withDatabase:database];
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] updateCountOfCasesAndReloadTableView];
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
        });
    });
}
/*
- (void) changeCountOfCases:(id) sender {
    [self.parentTableView reloadData];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlayView = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlayView.headingTitleLabel.text = @"";
    [self.syncOverlayView showOnlyTheView];
    [win addSubview:self.syncOverlayView];
    [self showAlertViewForCountOfCases];
}

- (void) showAlertViewForInspectionSamples {
    //    if (![[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter total count of Inspection Samples"
    //                                                        message:@""
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"Done"
    //                                              otherButtonTitles:nil];
    //        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //        alert.tag = 2;
    //        [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    //        //    UITextField* textfield = [alert textFieldAtIndex:0];
    //        //    textfield.text = self.buttonEditableForCountOfCases.titleLabel.text;
    //        [alert show];
    //    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter total count of Inspection Samples"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 2;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    //    UITextField* textfield = [alert textFieldAtIndex:0];
    //    textfield.text = self.buttonEditableForCountOfCases.titleLabel.text;
    [alert show];
    
}
*/
- (void) showStarRatingValueAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter New Score between 1-5"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    UITextField* textfield = [alert textFieldAtIndex:0];
    textfield.text = [NSString stringWithFormat:@"%d",self.oldStarRatingValue];
    [alert show];
}

- (void) showDeleteSampleAlert:(UIButton*)sender {
    //if only 1 sample left
    NSArray *allsavedAudits = self.delegate.productAudits;
    BOOL islastSample = NO;
    for(SavedAudit *savedAudit in allsavedAudits){
        if(savedAudit.productId == self.productId && savedAudit.auditsCount<=1){
            islastSample = YES;
        }
    }
    NSString *alertMessage = @"";
    self.inspectionSampleCountToDelete = sender.tag;
    if(islastSample){
        alertMessage = @"Deleting last sample will delete all audit data for this product.  Proceed?";
        //[self cannotDeleteSampleAlert];
        //return;
    }
    else{
        alertMessage = [NSString stringWithFormat:@"Delete Sample %d ?", self.inspectionSampleCountToDelete];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete",nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = 99;
    [alert show];
}

- (void) cannotDeleteSampleAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Cannot delete last sample"]
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    //alert.tag = 99;
    [alert show];
}

- (void) showNoSplitAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"No Samples Selected For Split"]
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    //alert.tag = 99;
    [alert show];
}

-(void) showSplitConfirmAlert:(NSString*)alertMessage{
    if(!alertMessage)
        alertMessage = @"";
    NSString* message = [NSString stringWithFormat:@"Enter number of cases to split \n Total cases: %d \n\n %@", self.savedAudit.countOfCases, alertMessage];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Split Delivery"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    UITextField* textfield = [alert textFieldAtIndex:0];
    //textfield.text = [NSString stringWithFormat:@"%d",self.oldStarRatingValue];
    [alert show];
}

- (NSString *) getTableCreateStatmentForSummary {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", TBL_SAVED_SUMMARY];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@ DEFAULT 0,",COL_SPLIT_GROUP_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PRODUCT_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_PRODUCT_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_COUNT_OF_CASES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_COUNT_OF_CASES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_MASTER_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_AUDIT_GROUP_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_INSPECTION_STATUS, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_USERENTERED_SAMPLES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_USERENTERED_NOTIFICATION, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_SUMMARY, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}
#pragma SPLIT_PRODUCT_DELIVERY

-(void)splitButtonTouched {
    NSMutableArray* samplesForSplit = [self getAuditCountsForSplit];
    if([samplesForSplit count] > 0){
        self.splitModeOn = YES;
        [self showSplitConfirmAlert:nil];
        //more split logic
    }else{
        [self showNoSplitAlert];
    }
    
}

-(NSMutableArray*) getAuditCountsForSplit{
    NSMutableArray* samplesForSplit = [[NSMutableArray alloc]init];
    for(SummaryInspectionSamples *sample in self.inspectionSamples){
        if(sample.needSplit){
            NSNumber *count = [NSNumber numberWithInt:sample.sampleCount];
            [samplesForSplit addObject:count];
        }
    }
 
 return samplesForSplit;
 }

-(void) splitAuditedProductGroup{
    UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
    [activityView setCustomMessage:@"Splitting Groups.."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [activityView show:self withOperation:nil showCancel:NO];
    }
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        
        //the audits with this split group ID will be further split
        if([self.savedAudit.splitGroupId isEqualToString:@""])
            self.savedAudit.splitGroupId = [Inspection sharedInspection].currentSplitGroupId; // [NSString stringWithFormat:@"%d", 0];
        NSString* currentSplitGroupId = self.savedAudit.splitGroupId;
        NSString* newSplitGroupId = [DeviceManager getCurrentTimeString];
        int productId = self.productId;

        //refersh page
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        
        //[self.summary deleteSummaryForProductWithGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID: [[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withDatabase:nil];
        //update summary table
        
        
        //TBL_SAVED_AUDITS -
        //update individual audits rows with the split-group-id
        
            NSMutableArray* splitAuditCounts = [self getAuditCountsForSplit];
            for(NSNumber *number in splitAuditCounts){
                int count = number.intValue;
                if(!aggregateSamplesMode) {
                NSString *updateAuditQuery = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@=%@ AND %@=%d AND %@=%d AND %@=%d", TBL_SAVED_AUDITS, COL_SPLIT_GROUP_ID,newSplitGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_AUDIT_COUNT, count,COL_PRODUCT_GROUP_ID, self.savedAudit.productGroupId];
                //NSLog(@"UpdateAuditQuery: %@",updateAuditQuery);
                [database executeUpdate:updateAuditQuery];
            }
        }
        
        //TBL_SAVED_SUMMARY
        //duplicate the current row and modify columns (split-group-id, count of cases)
        NSString *queryForCurrentGroup = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, self.savedAudit.productId, COL_PRODUCT_GROUP_ID, self.savedAudit.productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_SPLIT_GROUP_ID,currentSplitGroupId];
        //NSLog(@"queryForCurrentGroup: %@",queryForCurrentGroup);
        FMResultSet *queryForCurrentGroupResults = [database executeQuery:queryForCurrentGroup];
        int countOfCases = 0;
        int auditGroupId = 0;
        NSString* inspectionStatus = @"";
        int userEnteredInspectionSamples = 0;
        NSString* userEnteredNotification = @"";
        NSString* summary;
        while ([queryForCurrentGroupResults next]) {
            countOfCases = [[queryForCurrentGroupResults stringForColumn:COL_COUNT_OF_CASES] integerValue];
            auditGroupId =[[queryForCurrentGroupResults stringForColumn:COL_AUDIT_GROUP_ID] integerValue];
            inspectionStatus = [queryForCurrentGroupResults stringForColumn:COL_INSP_STATUS];
            userEnteredInspectionSamples =[[queryForCurrentGroupResults stringForColumn:COL_USERENTERED_SAMPLES] integerValue];
        }
        int newCountOfCases = countOfCases - self.splitCount;
        int newUserEnteredInspectionSamples = userEnteredInspectionSamples -[splitAuditCounts count];
        if(aggregateSamplesMode)
            newUserEnteredInspectionSamples = 1; //the split sample will have 1 sample to begin
        [database executeUpdate:@"insert into SAVED_SUMMARY (SPLIT_GROUP_ID, product_id, productGroup_id, count_of_cases, AUDIT_MASTER_ID, AUDIT_GROUP_ID,INSPECTION_STATUS,user_entered_inspection_samples,user_entered_notification,SUMMARY) values (?,?,?,?,?,?,?,?,?,?)",
            newSplitGroupId,
            [NSString stringWithFormat:@"%d", self.savedAudit.productId],
            [NSString stringWithFormat:@"%d", self.savedAudit.productGroupId],
            [NSString stringWithFormat:@"%d", self.splitCount],
            [Inspection sharedInspection].auditMasterId,
            [NSString stringWithFormat:@"%d", auditGroupId],
            inspectionStatus,
            [NSString stringWithFormat:@"%d", newUserEnteredInspectionSamples],
            userEnteredNotification,
            summary];
        
        //update the count of cases for the existing
        NSString *updateExistingSummaryRowQuery = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@',%@=%d WHERE %@=%@ AND %@=%d AND %@='%@'", TBL_SAVED_SUMMARY, COL_COUNT_OF_CASES,[NSString stringWithFormat:@"%d", newCountOfCases], COL_USERENTERED_SAMPLES,newUserEnteredInspectionSamples, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_PRODUCT_ID, productId, COL_SPLIT_GROUP_ID, self.savedAudit.splitGroupId];
        //NSLog(@"updateExistingSummaryRowQuery: %@",updateExistingSummaryRowQuery);
        //[[DBManager sharedDBManager] executeUpdateUsingFMDataBase: withDatabasePath:DB_APP_DATA];
        [database executeUpdate:updateExistingSummaryRowQuery];
        
        //for aggregate mode - add additonal row of audit for the split group
        if(aggregateSamplesMode){
            NSString *queryOriginalAggregateAudit = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_AUDITS,  COL_PRODUCT_GROUP_ID, self.savedAudit.productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_SPLIT_GROUP_ID,self.savedAudit.splitGroupId];
            FMResultSet *queryResult = [database executeQuery:queryOriginalAggregateAudit];
            NSString* auditJson = @"";
            NSString* productName = @"";
            NSString* images = @"";
            NSString* auditGroup = @"";
            while ([queryResult next]) {
                countOfCases = [[queryResult stringForColumn:COL_COUNT_OF_CASES] integerValue];
                auditGroup =[queryResult stringForColumn:COL_AUDIT_GROUP_ID];
                inspectionStatus = [queryResult stringForColumn:COL_INSP_STATUS];
                auditJson = [queryResult stringForColumn:COL_AUDIT_JSON];
                productName =  [queryResult stringForColumn:COL_PRODUCT_NAME];
                images =[queryResult stringForColumn:COL_IMAGES];
                userEnteredInspectionSamples =[[queryResult stringForColumn:COL_USERENTERED_SAMPLES] integerValue];
            }
            
            NSString *cleanDuplicateJson = [self createCleanDuplicateAudit:auditJson withAuditGroupId:auditGroup];
            NSString *cleanImagesJson = [self createCleanImagesJson];
            
            [database executeUpdate:@"insert into SAVED_AUDITS (SPLIT_GROUP_ID, productGroup_id, count_of_cases, AUDIT_MASTER_ID, AUDIT_GROUP_ID,user_entered_inspection_samples, AUDIT_PRODUCT_ID, AUDIT_JSON, product_name,IMAGES, INSP_STATUS, audit_count) values (?,?,?,?,?,?,?,?,?,?,?,?)",
             newSplitGroupId,
             [NSString stringWithFormat:@"%d", self.savedAudit.productGroupId],
             [NSString stringWithFormat:@"%d", self.splitCount],
             [Inspection sharedInspection].auditMasterId,
             auditGroup,
             [NSString stringWithFormat:@"%d", newUserEnteredInspectionSamples],
             [NSString stringWithFormat:@"%d", self.savedAudit.productId],
             cleanDuplicateJson,
             productName,
             cleanImagesJson,
             inspectionStatus,
             [NSString stringWithFormat:@"%d", 1]];
        }else {
            //update the auditCounts for original group audits - from 1..x
            NSString *queryOriginalGroupAudits = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_AUDITS,  COL_PRODUCT_GROUP_ID, self.savedAudit.productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_SPLIT_GROUP_ID,self.savedAudit.splitGroupId];
            NSLog(@"queryOriginalGroupAudits: %@",queryOriginalGroupAudits);
            FMResultSet *queryOriginalGroupAuditsResults = [database executeQuery:queryOriginalGroupAudits];
            NSMutableArray* auditCountsForCurrentGroup = [[NSMutableArray alloc]init];
            while ([queryOriginalGroupAuditsResults next]) {
                [auditCountsForCurrentGroup addObject:[queryOriginalGroupAuditsResults stringForColumn:COL_AUDIT_COUNT]];
            }
            
            for(int i=0; i<[auditCountsForCurrentGroup count]; i++){
                int oldAuditCount = [[auditCountsForCurrentGroup objectAtIndex:i] integerValue];
                NSString *updateAuditQuery = [NSString stringWithFormat:@"UPDATE %@ SET %@=%d WHERE %@=%d AND %@=%@ AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_COUNT,i+1, COL_AUDIT_COUNT, oldAuditCount, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_SPLIT_GROUP_ID, self.savedAudit.splitGroupId];
                NSLog(@"UpdateAuditQuery: %@",updateAuditQuery);
                [database executeUpdate:updateAuditQuery];
            }
            
            //update the auditCounts for new split group audits - from 1..x
            NSString *querySplitGroupAudits = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_AUDITS,  COL_PRODUCT_GROUP_ID, self.savedAudit.productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_SPLIT_GROUP_ID,newSplitGroupId];
            //NSLog(@"querySplitGroupAudits: %@",querySplitGroupAudits);
            FMResultSet *querySplitGroupAuditsResults = [database executeQuery:querySplitGroupAudits];
            NSMutableArray* auditCountsForSplitGroup = [[NSMutableArray alloc]init];
            while ([querySplitGroupAuditsResults next]) {
                [auditCountsForSplitGroup addObject:[querySplitGroupAuditsResults stringForColumn:COL_AUDIT_COUNT]];
            }
            
            for(int i=0; i<[auditCountsForSplitGroup count]; i++){
                int oldAuditCount = [[auditCountsForSplitGroup objectAtIndex:i] integerValue];
                NSString *updateAuditQuery = [NSString stringWithFormat:@"UPDATE %@ SET %@=%d WHERE %@=%d AND %@=%@ AND %@=%d AND %@=%@", TBL_SAVED_AUDITS, COL_AUDIT_COUNT,i+1, COL_AUDIT_COUNT, oldAuditCount,COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId, COL_AUDIT_PRODUCT_ID, productId, COL_SPLIT_GROUP_ID, newSplitGroupId];
                //NSLog(@"UpdateAuditQuery: %@",updateAuditQuery);
                [database executeUpdate:updateAuditQuery];
            }
            
        }
       
        //self.splitGroupId = newSplitGroupId;
      //generate summary for old group and the new group
        NSLog(@"Recalculating summary for existing row - splitGroupId: %@", newSplitGroupId);
        [self recalculateSummaryObjectWithDatabase:database withSplitGroupId:newSplitGroupId];
        NSLog(@"Recalculating summary for new row - splitGroupId: %@", self.savedAudit.splitGroupId);
        [self recalculateSummaryObjectWithDatabase:database withSplitGroupId:self.savedAudit.splitGroupId];
        
        [database close];
        //refresh saved audits
         [self.delegate refreshSavedAudits];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parentTableView reloadData];
            [[self delegate] updateCountOfCasesAndReloadTableView];
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
            [self closeButtonTouched];
        });
    });
}

-(NSString*) createCleanDuplicateAudit:(NSString*)auditJson withAuditGroupId:(NSString*)auditGroupId {
    NSError* err = nil;
    Audit* currentAuditJson = [[Audit alloc] initWithString:auditJson error:&err];
    //NSLog(@"ORIGINAL AUDIT: %@", [currentAuditJson toJSONString]);
    //reset variables like product ratings, images, auditIDs
    currentAuditJson.auditData.submittedInfo.productRatings = (NSArray<AuditApiRating>*)[[NSArray alloc]init];
    currentAuditJson.auditData.images = [[NSArray alloc]init];
    NSString *deviceID = [DeviceManager getDeviceID];
    NSString *auditMasterId = [Inspection sharedInspection].auditMasterId;
    NSString *auditGroupString = auditGroupId;
    NSString *auditTransacString = [DeviceManager getCurrentTimeString];
    NSString *startTime = [DeviceManager getCurrentTimeString];
    NSString *endTime = [DeviceManager getCurrentTimeString];
    NSString *auditId = [NSString stringWithFormat:@"%@-%@-%@-%@", deviceID, auditMasterId, auditGroupString, auditTransacString];
    currentAuditJson.auditData.audit.id = auditId;
    currentAuditJson.auditData.audit.start = startTime;
    currentAuditJson.auditData.audit.end = endTime;
    NSString *modifiedAudit = [currentAuditJson toJSONString];
    //NSLog(@"MODIFIED AUDIT: %@", modifiedAudit);
    return modifiedAudit;
}

-(NSString*) createCleanImagesJson {
    ImageArray* images = [[ImageArray alloc]init];
    images.images = [[NSArray<Image> alloc]init];
    NSString* imagesJson = [images toJSONString];
    return imagesJson;
}


-(void) updateStarRatingScore:(int)ratingId{
    UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
    [activityView setCustomMessage:@"Updating.."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [activityView show:self withOperation:nil showCancel:NO];
    }
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        //update audits
        [[Inspection sharedInspection] updateStarRatingWithScore:self.newStarRatingValue ratingId:self.starRatingToModify  productId:self.productId auditCount:self.auditCountToModify updateAll:NO];
        //refersh page
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        [self recalculateSummaryObjectWithDatabase:database withSplitGroupId:self.savedAudit.splitGroupId];
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
            
            self.starRatingToModify = 0;
            self.newStarRatingValue = 0;
            self.auditCountToModify = 0;
            self.oldStarRatingValue = 0;
            
            [self initSamplesStructure];
            [self.subMenuTableView reloadData];
        });
    });
}

-(void) updateStarRatingScoreAverage:(int)ratingId withNewAverage:(int)newAverage withProductId:(int)productId{
    UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
    [activityView setCustomMessage:@"Updating.."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [activityView show:self withOperation:nil showCancel:NO];
    }
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        //update audits
        [[Inspection sharedInspection] updateStarRatingWithScore:newAverage ratingId:ratingId productId:productId auditCount:self.auditCountToModify updateAll:YES];
        //refersh page
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        [self recalculateSummaryObjectWithDatabase:database withSplitGroupId:self.savedAudit.splitGroupId];
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
            
            self.starRatingToModify = 0;
            self.newStarRatingValue = 0;
            self.auditCountToModify = 0;
            self.oldStarRatingValue = 0;
            
            [self initSamplesStructure];
            [self.subMenuTableView reloadData];
            self.updateAveragesTableView = YES; //reload avergaes table
        });
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) { //handle OK and cancel
        if(buttonIndex == alertView.firstOtherButtonIndex){
            NSString *value = [alertView textFieldAtIndex:0].text;
            if (![value isEqualToString:@""] && !([value intValue]>5) && !([value intValue]<1)) {
                self.newStarRatingValue = [[alertView textFieldAtIndex:0].text intValue];
                [self performSelector:@selector(updateStarRatingScore:) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
            } else {
                [self showStarRatingValueAlert];
            }
        }
    } else if(alertView.tag == 99){ //delete sample
        if(buttonIndex == alertView.firstOtherButtonIndex){
            [self performSelector:@selector(deleteSample:) withObject:nil afterDelay:0];
        } else {
            self.inspectionSampleCountToDelete = 0;
        }
    }else if(alertView.tag == 100){ //split sample
        if(buttonIndex == alertView.firstOtherButtonIndex){
            NSString *value = [alertView textFieldAtIndex:0].text;
            /*if (![value isEqualToString:@""] && !([value intValue]>self.savedAudit.countOfCases) && !([value intValue]<1)) { //fix the max !!
                self.splitCount = [[alertView textFieldAtIndex:0].text intValue];
                [self performSelector:@selector(splitAuditedProductGroup) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
            }else if(!aggregateSamplesMode && self.savedAudit.auditsCount==1){
                [self showSplitConfirmAlert];
            }
            else {
                [self showSplitConfirmAlert];
            }*/
            
            if ([value isEqualToString:@""] || ([value intValue]<1)){
                [self showSplitConfirmAlert:@"Enter a valid count "];
                
            }else if(([value intValue]>self.savedAudit.countOfCases)){
                [self showSplitConfirmAlert:@"Value should be less than count Of cases"];
                
            }else if(!aggregateSamplesMode && self.savedAudit.auditsCount==1){
                [self showSplitConfirmAlert:@"need more than 1 audit to split"];
                
            }else{
                self.splitCount = [[alertView textFieldAtIndex:0].text intValue];
                [self performSelector:@selector(splitAuditedProductGroup) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
            }
        }
    }else {
        if(buttonIndex == alertView.firstOtherButtonIndex){
            if (![[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
                [self performSelector:@selector(updateInspectionSamplesLocal:) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
            } else {
                //[self showAlertViewForInspectionSamples];
            }
        }
    }
}

-(void) deleteSample:(UIButton*)sender {
    //NSLog(@"inspection sample to delete is: %d",sender.value);
    UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
    [activityView setCustomMessage:@"Updating.."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [activityView show:self.parentTableView withOperation:nil showCancel:NO];
    }
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        //delete audit
        [[Inspection sharedInspection] deleteAuditWithId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] forAuditCount:self.inspectionSampleCountToDelete];
        BOOL isLastSample = NO;
        //if last sample deleted
        NSArray *allsavedAudits = self.delegate.productAudits;
        for(SavedAudit *savedAudit in allsavedAudits){
            if(savedAudit.productId == self.productId && savedAudit.auditsCount<=1){
                self.savedAudit.userEnteredAuditsCount = 0;
                
                //delete summary JSON
                [self.summary deleteSummaryForProductWithGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID: [[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withDatabase:nil];
                
                //reset local summary object
                self.summary.numberOfInspections = 0;
                self.summary.averagePercentageOfCases = 0;
                self.summary.inspectionStatus = @"";
                
                //refresh table view
               // [self.delegate refreshSavedAudits];
                //[self updateCountOfCasesLocal:@"0"];
                isLastSample = YES;
            }
        }
           
        //else just update the auditCount
        self.savedAudit.auditsCount--;
       
        //refresh summary
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        [self recalculateSummaryObjectWithDatabase:database withSplitGroupId:self.savedAudit.splitGroupId];
        [database close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
            
                [self initSamplesStructure];
                [self.subMenuTableView reloadData];
                self.updateAveragesTableView = YES; //reload avergaes table
            if(isLastSample){
                [self.parentTableView collapseCurrentlyExpandedIndexPaths];
                [self.subMenuTableView removeFromSuperview];
                [self closeButtonTouched]; //close view
            }
        });
    });
}

-(void) editSample:(UIButton*)sender {
    //NSLog(@"inspection sample to delete is: %d",sender.value);
    //comment out to avoid crash issue
    [self.delegate modifyInspectionWithTag:self.summaryScreenRow withSection:_summaryScreenSection withAuditCount:sender.tag];
    [self closeButtonTouched];
    
}

-(void) addToSplit:(UIButton*)sender {
    //NSLog(@"inspection sample to delete is: %d",sender.value);
    //[self.delegate modifyInspectionWithTag:self.productId withSection:sender.tag];
    //[self closeButtonTouched];
     SummaryInspectionSamples *value =[self.inspectionSamples objectAtIndex:sender.tag];
    value.needSplit = !value.needSplit;
     [self.subMenuTableView reloadData];
}


- (void) updateCountOfCasesLocal: (NSString *) text {
            FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        [self.summary updateNumberOfInspectionsInDB:[text integerValue] withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID: [[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
        [database close];
}
/*
- (void) updateInspectionSamplesLocal: (NSString *) text {
    NSString *countOfCasesNew = text;
    UserNetworkActivityView *activityView = [UserNetworkActivityView sharedActivityView];
    [activityView setCustomMessage:@"Updating.."];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [activityView show:self withOperation:nil showCancel:NO];
    }
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        [self.summary updateNumberOfInspectionsInDB:[countOfCasesNew integerValue] withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID: [[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withDatabase:database];
        [self recalculateSummaryObjectWithDatabase:database];
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
        });
    });
}*/


- (void) recalculateSummaryObjectWithDatabase:(FMDatabase *)database withSplitGroupId:(NSString*)splitGroupId {
    Product *productLocal = self.globalProduct;
    if (!productLocal) {
        productLocal = [[Inspection sharedInspection] getProduct:self.savedAudit.productGroupId withProductID:self.savedAudit.productId];
    }
    [self.summary getSummaryOfAudits:productLocal withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withSplitGroupId:splitGroupId withDatabase:database];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parentTableView reloadData];
        //[[self delegate] updateCountOfCasesAndReloadTableView];
    });
    //[self.delegate updateCountOfCasesAndReloadTableView];//update the inspectionStatusViewController data
    
}

@end
