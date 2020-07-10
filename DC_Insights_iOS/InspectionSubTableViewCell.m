//
//  InspectionTableView.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/29/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "InspectionSubTableViewCell.h"
#import "Inspection.h"
#import "SummaryDetailsTableViewCell.h"

#define cellHeightForDefect 84

@implementation InspectionSubTableViewCell

@synthesize inspectionTotalSummaryTableViewCell;
@synthesize modifyInspectionButton;
@synthesize changeStatusButton;
@synthesize buttonEditableForCountOfCases;
@synthesize switchview;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 300, 50);
        [self buttonsSetup];
        UITableView *subMenuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        subMenuTableView.tag = 100;
        subMenuTableView.delegate = self;
        subMenuTableView.dataSource = self;
        subMenuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        subMenuTableView.scrollEnabled = NO; //disable scroll to fix DI-1983
        //subMenuTableView.backgroundColor = [UIColor blueColor];
        
        [self addSubview:subMenuTableView]; // add it cell
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 100.0)];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //footerView.frame = CGRectMake(0.0, 0.0, 320.0, 50.0);
        }
        [footerView addSubview:self.modifyInspectionButton];
        [footerView addSubview:self.changeStatusButton];
        subMenuTableView.tableFooterView = footerView;
         self.closeButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(0.0,30.0,25.0,25.0)];
        
    }
    return self;
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
    
    [self calculateHeightForTheInspectionDefectCell2];
    UITableView *subMenuTableView =(UITableView *) [self viewWithTag:100];
    [subMenuTableView reloadData];
    //subMenuTableView.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5,    self.bounds.size.height-5);//set the frames for tableview
    subMenuTableView.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5,    [self getTotalHeightForTableView]-5);
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
    self.heightDictForRatings = [[NSMutableDictionary alloc] init];
    for(Rating *aRating in self.summary.allRatingsList) {
        int heightForRating = 10;
        heightForRating = heightForRating + 20;
        for(Defect *aDefect in aRating.defects) {
            heightForRating = heightForRating + 15;
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
    if(self.globalProduct.program_id == 1){
    int numberOfSections = 9;
    if (sendNotificationOptionEnabled) {
        numberOfSections = 10;
    }
    return numberOfSections;
    }else{
        int numberOfSections = 7;
        if (sendNotificationOptionEnabled) {
            numberOfSections = 8;
        }
        return numberOfSections;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.globalProduct.program_id == 1){
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1; //1; //for the text "Score and Defect Totals"
    } else if (section == 3) {
        return 1;
    } else if (section == 4) {
        return 2;
    } else if (section == 5) {
        return [self.summary.allRatingsList count];
    } else if (section == 6) {
        int total = 1 + [self.summary.allTotalsList count];
        return 0;//total;
    } else if (section == 7) {
        return 1;
    } else if(section == 8){
        return 1;
    } else if(section == 9){
           return 1;
       }

    return 0;
    }else{
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return 1;
        } else if (section == 2) {
            return 2; //1; //for the text "Score and Defect Totals"
        } else if (section == 3) {
            return [self.summary.allRatingsList count];
        } else if (section == 4) {
            int total = 1 + [self.summary.allTotalsList count];
            return 0;//total;
        } else if (section == 5) {
            return 1;
        } else if (section == 6) {
            return 1;
        } else if (section == 7) {
            return 1;
        }
        return 0;
    }
}

//calculate total height of this view and init tableview
//to avoid scrolling tableview
-(int)getTotalHeightForTableView {
    int totalHeight = 0;
    int ratingsHeight  = 0;
    NSArray* heightOfRatingsArray = [self.heightDictForRatings allKeys];
    for(NSString *ratingId in heightOfRatingsArray){
        int height = [[self.heightDictForRatings objectForKey:[NSString stringWithFormat:@"%@", ratingId]] integerValue];
        ratingsHeight+=height;
    }
    totalHeight = 30 + 30 + (40 * 2) + ratingsHeight + 30 + 30 +33;
    totalHeight += 50 + 50; //buttons
   // totalHeight += 40;
    return totalHeight;
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
    id notificationStatus;
    NSString *cellID = [NSString stringWithFormat:@"cellID %d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
       {
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
       }
       cell.detailTextLabel.textColor = [UIColor blackColor];
       cell.accessoryView = nil;
    if(self.globalProduct != nil){
    if(self.globalProduct.program_id == 1){
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Inspection Samples";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.summary.numberOfInspections];
        cell.detailTextLabel.attributedText = [self getUnderlineTextForString:[NSString stringWithFormat:@"%d", self.summary.numberOfInspections]];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        
    } else if (indexPath.section == 1) {
        if(self.globalProduct.program_id == 1){
            Rating *quantityOfItems = [self.globalProduct.ratings objectAtIndex:0];
            cell.textLabel.text = quantityOfItems.displayName;
        }else{
            cell.textLabel.text = @"Total Count Of Cases";
        }
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.summary.totalCountOfCases];
        cell.detailTextLabel.attributedText = [self getUnderlineTextForString:[NSString stringWithFormat:@"%d", self.summary.totalCountOfCases]];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
//        [self buttonCountOfCasesSetup];
//        NSString *count = [NSString stringWithFormat:@"%d", self.summary.totalCountOfCases];
//        if (count && ![count isEqualToString:@""]) {
//            [self.buttonEditableForCountOfCases setTitle:count forState:UIControlStateNormal];
//        }
//        [cell addSubview:self.buttonEditableForCountOfCases];
    } else if (indexPath.section == 2) {
        
        cell.textLabel.text = @"Percentage Of Cases";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f %%", self.summary.averagePercentageOfCases];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 29, self.frame.size.width - 30, 1)];
        line.backgroundColor = [UIColor blackColor];
        [cell.contentView addSubview:line];
         
        
    } else if (indexPath.section == 3) {
        if(self.globalProduct.program_id == 1){
            Rating *quantityOfItems = [self.globalProduct.ratings objectAtIndex:1];
            cell.textLabel.text = quantityOfItems.displayName;
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.summary.inspectionCountOfCases];
            cell.detailTextLabel.attributedText = [self getUnderlineTextForString:[NSString stringWithFormat:@"%d", self.summary.inspectionCountOfCases]];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        }
    } else if (indexPath.section == 4) {
        if(indexPath.row == 0){
        if(self.globalProduct.program_id == 1){
            cell.textLabel.text = @"Percentage Of Cases";
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f %%", self.summary.inspectionPercentageOfCases];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 29, self.frame.size.width - 30, 1)];
            line.backgroundColor = [UIColor blackColor];
            [cell.contentView addSubview:line];
        }
        }else{
            cell.textLabel.text = @"Score and Defect Totals";
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f %%", self.summary.averagePercentageOfCases];
            //cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                //self.closeButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(0.0,30.0,20.0,20.0)];
                self.closeButton.titleLabel.text = @"Close";
                [self.closeButton setBackgroundImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
               /* [self.closeButton addTarget:self
                                action:@selector(showSummaryDetails)
                      forControlEvents:UIControlEventTouchUpInside];*/
                cell.accessoryView = self.closeButton;
        }
    } else if (indexPath.section == 5){
        InspectionDefectTableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        //if(cell == nil)
        {
            cell = [[InspectionDefectTableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        Rating *rating = [self.summary.allRatingsList objectAtIndex:indexPath.row];
        cell.ratingName = rating.displayName; //DI-2653
        cell.ratingValue = rating.value;
        cell.allDefectsList = rating.defects;
        cell.ratingId = rating.ratingID;
        cell.productId = self.savedAudit.productId;
        cell.summaryAveragedelegate = self;
        [cell.subMenuTableView reloadData];
        //self.updateAveragesTableView = NO;
        return  cell;
    }
        else if (indexPath.section == 6) {
        
        /*if (indexPath.row == 0) {
            cell.textLabel.text = @"Totals";
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
            cell.detailTextLabel.text = @"";
        } else {
            Severity *severity = [self.summary.allTotalsList objectAtIndex:indexPath.row - 1];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
            cell.textLabel.text = severity.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f%%", severity.inputOrCalculatedPercentage];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        }*/
    } else if (indexPath.section == 7) {
        cell.textLabel.text = @"Defects Grand Total";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f%%", self.summary.grandTotal];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 29, self.frame.size.width - 30, 1)];
        line.backgroundColor = [UIColor blackColor];
        [cell.contentView addSubview:line];
    } else if (indexPath.section == 8) {
        cell.textLabel.text = @"Inspection Status";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        if([self.savedAudit.previousInspectionStatus length] != 0){
            if(([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) || ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) || ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"])){
                if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) {
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];
                } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) {
                    cell.detailTextLabel.textColor = [UIColor redColor];
                } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
                    cell.detailTextLabel.textColor = [UIColor orangeColor];
                } else {
                    cell.detailTextLabel.textColor = [UIColor greenColor];
                }
            }else{
            if ([[self.savedAudit.previousInspectionStatus lowercaseString] isEqualToString:@"accept"]) {
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];
            } else if ([[self.savedAudit.previousInspectionStatus lowercaseString] isEqualToString:@"reject"]) {
                cell.detailTextLabel.textColor = [UIColor redColor];
            } else if ([[self.savedAudit.previousInspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
                cell.detailTextLabel.textColor = [UIColor orangeColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor greenColor];
            }
            }
        }else{
        if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept"]) {
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];
        } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"reject"]) {
            cell.detailTextLabel.textColor = [UIColor redColor];
        } else if ([[self.savedAudit.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor greenColor];
        }
        }
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        int chosenId = -1;
        int i = 0;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

        NSArray *allInspectionStatuses = [userDefaults objectForKey:@"allInspectionStatuses"];
        NSArray *allIds = [userDefaults objectForKey:@"allIds"];
        NSArray *notifications = [userDefaults objectForKey:@"notifications"];
        NSArray *allDefaultStatuses = [userDefaults objectForKey:@"allDefaultStatuses"];
        NSArray *defaultIds = [userDefaults objectForKey:@"defaultIds"];
        int count = allDefaultStatuses.count;

        while( i < count){
            NSString *defaultStatus = allDefaultStatuses[i];
            NSString *summaryStatus = self.summary.inspectionStatus;
            if([defaultStatus isEqualToString:summaryStatus])
            {
                chosenId = [defaultIds[i] intValue];
                break;
            }
            i = i + 1;
        }
        i = 0;
        NSString *selectedStatus = @"";
        if(chosenId == -1)
        {
            selectedStatus = self.summary.inspectionStatus;
            int j = 0;
            while(j < count){
                if([selectedStatus isEqualToString:allDefaultStatuses[j]]){
                    FMDatabase *database;
                    database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
                    [database open];
                    int changed = [self.summary getUserEnteredChangedFromDB:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterId:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withProductGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withDatabase:database];
                    [database close];
                    if(changed == 0)
                    {
                        notificationStatus = notifications[i];
                        if([notificationStatus boolValue] == YES)
                        {
                            self.summary.sendNotification = YES;
                        }else{
                            self.summary.sendNotification = NO;
                        }
                    }
                    break;
                }
                j += 1;
            }
        }
        count = allInspectionStatuses.count;
        while(i < count){
            id savedAuditId = allIds[i];
            if(chosenId == [savedAuditId intValue]){
                selectedStatus = allInspectionStatuses[i];
                FMDatabase *database;
                database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
                [database open];
                int changed = [self.summary getUserEnteredChangedFromDB:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterId:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withProductGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withDatabase:database];
                [database close];
                if(changed == 0)
                {
                    notificationStatus = notifications[i];
                    if([notificationStatus boolValue] == YES)
                    {
                        self.summary.sendNotification = YES;
                    }else{
                        self.summary.sendNotification = NO;
                    }
                }
                break;
            }
            i = i + 1;
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", selectedStatus];
    } else if (indexPath.section == 9) {
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
    }else{
            if (indexPath.section == 0) {
                cell.textLabel.text = @"Inspection Samples";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.summary.numberOfInspections];
                cell.detailTextLabel.attributedText = [self getUnderlineTextForString:[NSString stringWithFormat:@"%d", self.summary.numberOfInspections]];
                cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                
            } else if (indexPath.section == 1) {
                cell.textLabel.text = @"Total Count Of Cases";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.summary.totalCountOfCases];
                cell.detailTextLabel.attributedText = [self getUnderlineTextForString:[NSString stringWithFormat:@"%d", self.summary.totalCountOfCases]];
                cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
        //        [self buttonCountOfCasesSetup];
        //        NSString *count = [NSString stringWithFormat:@"%d", self.summary.totalCountOfCases];
        //        if (count && ![count isEqualToString:@""]) {
        //            [self.buttonEditableForCountOfCases setTitle:count forState:UIControlStateNormal];
        //        }
        //        [cell addSubview:self.buttonEditableForCountOfCases];
            } else if (indexPath.section == 2) {
                if(indexPath.row == 0) {
                cell.textLabel.text = @"Percentage Of Cases";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f %%", self.summary.averagePercentageOfCases];
                cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 29, self.frame.size.width - 30, 1)];
                line.backgroundColor = [UIColor blackColor];
                [cell.contentView addSubview:line];
                } else {
                cell.textLabel.text = @"Score and Defect Totals";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                //cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f %%", self.summary.averagePercentageOfCases];
                //cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                    //self.closeButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(0.0,30.0,20.0,20.0)];
                    self.closeButton.titleLabel.text = @"Close";
                    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
                   /* [self.closeButton addTarget:self
                                    action:@selector(showSummaryDetails)
                          forControlEvents:UIControlEventTouchUpInside];*/
                    cell.accessoryView = self.closeButton;
                }
                
            } else if (indexPath.section == 3) {
                InspectionDefectTableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                //if(cell == nil)
                {
                    cell = [[InspectionDefectTableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
                }
                Rating *rating = [self.summary.allRatingsList objectAtIndex:indexPath.row];
                cell.ratingName = rating.displayName; //DI-2653
                cell.ratingValue = rating.value;
                cell.allDefectsList = rating.defects;
                cell.ratingId = rating.ratingID;
                cell.productId = self.savedAudit.productId;
                cell.summaryAveragedelegate = self;
                [cell.subMenuTableView reloadData];
                //self.updateAveragesTableView = NO;
                return  cell;
            } else if (indexPath.section == 4) {
                /*if (indexPath.row == 0) {
                    cell.textLabel.text = @"Totals";
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:13.0];
                    cell.detailTextLabel.text = @"";
                } else {
                    Severity *severity = [self.summary.allTotalsList objectAtIndex:indexPath.row - 1];
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                    cell.textLabel.text = severity.name;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f%%", severity.inputOrCalculatedPercentage];
                    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
                }*/
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
                if ([[self.summary.inspectionStatus lowercaseString] isEqualToString:@"accept"]) {
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.2 alpha:1];
                } else if ([[self.summary.inspectionStatus lowercaseString] isEqualToString:@"reject"]) {
                    cell.detailTextLabel.textColor = [UIColor redColor];
                } else if ([[self.summary.inspectionStatus lowercaseString] isEqualToString:@"accept with issues"]) {
                    cell.detailTextLabel.textColor = [UIColor orangeColor];
                } else {
                    cell.detailTextLabel.textColor = [UIColor greenColor];
                }
                cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
                id chosenId;
                int i = 0;
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

                NSArray *allInspectionStatuses = [userDefaults objectForKey:@"allInspectionStatuses"];
                NSArray *allIds = [userDefaults objectForKey:@"allIds"];
                NSArray *notifications = [userDefaults objectForKey:@"notifications"];
                NSArray *allDefaultStatuses = [userDefaults objectForKey:@"allDefaultStatuses"];
                NSArray *defaultIds = [userDefaults objectForKey:@"defaultIds"];
                int count = allDefaultStatuses.count;

                while( i < count){
                    NSString *defaultStatus = allDefaultStatuses[i];
                    NSString *summaryStatus = self.summary.inspectionStatus;
                    if([defaultStatus isEqualToString:summaryStatus])
                    {
                        chosenId = defaultIds[i];
                        break;
                    }
                    i = i + 1;
                }
                i = 0;
                NSString *selectedStatus = @"";
                count = allInspectionStatuses.count;
                while(i < count){
                    id savedAuditId = allIds[i];
                    if(chosenId == savedAuditId){
                        selectedStatus = allInspectionStatuses[i];
                        FMDatabase *database;
                        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
                        [database open];
                        int changed = [self.summary getUserEnteredChangedFromDB:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterId:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withProductGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withDatabase:database];
                        [database close];
                        if(changed == 0)
                        {
                            notificationStatus = notifications[i];
                            if([notificationStatus boolValue] == YES)
                            {
                                self.summary.sendNotification = YES;
                            }else{
                                self.summary.sendNotification = NO;
                            }
                        }
                        break;
                    }
                    i = i + 1;
                }
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", selectedStatus];
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
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.switchview = nil;
}

-(void) showSummaryDetails{
    SummaryDetailsTableViewCell *cell = [[SummaryDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InspectionSubTableViewCell"];
    //cell.delegate = self.delegate;
    cell.savedAudit = self.savedAudit;
    NSLog(@"Saved Audit is: %@",self.savedAudit);
    cell.parentTableView = self.parentTableView;
    cell.summary = self.summary;
    cell.globalProduct = self.globalProduct;
    [cell initSamplesStructure];
    
    [self.window addSubview:cell];
    //add with transition
    /*[UIView transitionWithView:self.window
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromLeft //any animation
                    animations:^ { [self.window addSubview:cell]; }
                    completion:nil];*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSLog(@"insepction samples touched");
        //if ([[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
        if (aggregateSamplesMode) {
            [self showAlertViewForInspectionSamples];
        }
    } else if (indexPath.section == 1) {
        [self showAlertViewForCountOfCases];
    } else if( (indexPath.section == 2) && (indexPath.row == 1)) {
       /* SummaryDetailsTableViewCell *cell = [[SummaryDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InspectionSubTableViewCell"];
        //cell.delegate = self.delegate;
        cell.savedAudit = self.savedAudit;
        cell.parentTableView = self.parentTableView;
        cell.summary = self.summary;
        cell.globalProduct = self.globalProduct;
        [cell initSamplesStructure];
       
        [self.window addSubview:cell];*/
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.globalProduct.program_id == 1){
    // Returns 60.0 points for all subrows.
    if(indexPath.section == 2 && indexPath.row != 0){
        return 40;
    }
    
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 7 || indexPath.section == 8 || indexPath.section == 3 || indexPath.section == 4) {
        return 30;
    } else if (indexPath.section == 5) {
        Rating *aRating = [self.summary.allRatingsList objectAtIndex:indexPath.row];
        int height = [[self.heightDictForRatings objectForKey:[NSString stringWithFormat:@"%d", aRating.ratingID]] integerValue];
        return height;
    } else if (indexPath.section == 6) {
        return 0 ;//30.0f;
    } else if (indexPath.section == 9) {
        return 33.0f;
    } else {
        return 0;
    }
    }else{
        // Returns 60.0 points for all subrows.
        if(indexPath.section == 2 && indexPath.row != 0){
            return 40;
        }
        
        if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 5 || indexPath.section == 6) {
            return 30;
        } else if (indexPath.section == 3) {
            Rating *aRating = [self.summary.allRatingsList objectAtIndex:indexPath.row];
            int height = [[self.heightDictForRatings objectForKey:[NSString stringWithFormat:@"%d", aRating.ratingID]] integerValue];
            return height;
        } else if (indexPath.section == 4) {
            return 0 ;//30.0f;
        } else if (indexPath.section == 7) {
            return 33.0f;
        } else {
            return 0;
        }
    }
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
        [[Inspection sharedInspection] updateStarRatingWithScore:newAverage ratingId:ratingId productId:productId auditCount:0 updateAll:YES];
        //refersh page
        FMDatabase *database;
        database = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [database open];
        [self recalculateSummaryObjectWithDatabase:database];
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
            
            UITableView *subMenuTableView =(UITableView *) [self viewWithTag:100];
            [subMenuTableView reloadData];
            self.updateAveragesTableView = YES; //reload avergaes table
        });
    });
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
        [self.summary updateChangedInDB:1 withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID:[[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withProductGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withDatabase:database];
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
           // [[self delegate] updateCountOfCasesAndReloadTableView];
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
        });
    });
}

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter total count of Inspection Samples"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 2;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [alert show];
}

- (void) showAlertViewForInspectionSamplesError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter total count of Inspection Samples"
                                                    message:@"Samples cannot be greater than total cases"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 2;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [alert show];
}

- (void) showAlertForDeletingLastSample {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deleting last sample will delete all audit data for this product.  Proceed?"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.tag =3;
    [alert show];
}

- (void) showAlertViewForCountOfCases {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter total count of cases"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    UITextField* textfield = [alert textFieldAtIndex:0];
    textfield.text = self.buttonEditableForCountOfCases.titleLabel.text;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) { //handle OK and cancel
        if(buttonIndex == alertView.firstOtherButtonIndex){
            if (![[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
                [self performSelector:@selector(updateCountOfCasesLocal:) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
            } else {
                [self showAlertViewForCountOfCases];
            }
        }
    } else if(alertView.tag == 2){
        if(buttonIndex == alertView.firstOtherButtonIndex){
            if([[alertView textFieldAtIndex:0].text intValue]==0){ // if entered 0 - confirm
                [self showAlertForDeletingLastSample];
            }
            else if (![[alertView textFieldAtIndex:0].text isEqualToString:@""]) {
                int count = [[[alertView textFieldAtIndex:0] text]integerValue];
                if(count>self.summary.totalCountOfCases){
                    [self showAlertViewForInspectionSamplesError];
                }else
                [self performSelector:@selector(updateInspectionSamplesLocal:) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
            } else {
                [self showAlertViewForInspectionSamples];
            }
        }
    } else if(alertView.tag == 3){
        if(buttonIndex == alertView.firstOtherButtonIndex){
             [self performSelector:@selector(updateInspectionSamplesLocal:) withObject:[alertView textFieldAtIndex:0].text afterDelay:0];
        }
    }
}

- (void) updateCountOfCasesLocal: (NSString *) text {
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
        [self.summary updateCountOfCasesInDB:countOfCasesNew withInspectionCount:[NSString stringWithFormat:@"%d", self.summary.inspectionCountOfCases] withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withDatabase:database];
        [self recalculateSummaryObjectWithDatabase:database];
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
        });
    });
}

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
        
        //delete audit if last deleted sample
        if([text intValue]==0){
            //delete the audit JSON - fake audit will be generated at finish inspection stage
            [[Inspection sharedInspection] deleteAuditWithId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] forAuditCount:1];
            //delete summary JSON
            [self.summary deleteSummaryForProductWithGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID: [[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withDatabase:database];
            
            //reset local summary object
            self.summary.numberOfInspections = 0;
            self.summary.averagePercentageOfCases = 0;
            self.summary.inspectionStatus = @"";
            
            //refresh table view
            [self.delegate refreshSavedAudits];
            
        } else { // if not the last sample
            [self.summary updateNumberOfInspectionsInDB:[countOfCasesNew integerValue] withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withAuditMasterID: [[Inspection sharedInspection] auditMasterId] withProductId:[NSString stringWithFormat:@"%d", self.savedAudit.productId] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
            [self recalculateSummaryObjectWithDatabase:database];
        }
        [database close];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UserNetworkActivityView sharedActivityView].hidden)
                [[UserNetworkActivityView sharedActivityView] hide];
        });
    });
}

- (void) recalculateSummaryObjectWithDatabase: (FMDatabase *) database {
    Product *productLocal = self.globalProduct;
    if (!productLocal) {
        productLocal = [[Inspection sharedInspection] getProduct:self.savedAudit.productGroupId withProductID:self.savedAudit.productId];
    }
    [self.summary getSummaryOfAudits:productLocal withGroupId:[NSString stringWithFormat:@"%d", self.savedAudit.productGroupId] withSplitGroupId:[Inspection sharedInspection].currentSplitGroupId withDatabase:database];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parentTableView reloadData];
        [[self delegate] updateCountOfCasesAndReloadTableView];
    });
}

@end
