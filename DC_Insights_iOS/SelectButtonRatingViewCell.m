//
//  SelectButtonRatingViewCell.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "SelectButtonRatingViewCell.h"
#import "ProductRatingViewController.h"
#import "HPTCaseCodeViewController.h"
#import "OrderData.h"
#import "Inspection.h"
#import "AppDelegate.h"
#import "SelectButtonRatingPopUpCell.h"
#import "CollaborativeInspection.h"

@implementation SelectButtonRatingViewCell

@synthesize selectOptionButton;
@synthesize utilityButtonView;
@synthesize comboItems;
@synthesize poNumbersArray;
@synthesize grnArray;
@synthesize poplistviewDates;
@synthesize poplistview;
@synthesize flaggedPONumbers;
@synthesize flaggedGRNs;
@synthesize flaggedSuppliers;
@synthesize poAndDateDictionary;
@synthesize grnAndDateDictionary;
- (id)init
{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

+ (CGFloat) myCellHeight:(Rating*)theRating
{
    CGFloat questionViewHeight = [BaseTableViewCell myQuestionViewHeight:theRating];
    return (120 + questionViewHeight);
}

#pragma mark - Refresh state Method

- (void)configureFonts
{
    [super configureFonts];
    
    fontsSet = YES;
    self.selectOptionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.selectOptionButton.layer.borderWidth = 1.0;
    self.selectOptionButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.selectOptionButton.layer.cornerRadius = 1.0;
    //self.selectOptionButton.frame = CGRectMake(20, 2, 280, 38);
}

- (void) addAdditionalButtons {
    [super addAdditionalButtons];
}

- (void) getPONumbersAndFilterThem {
    NSArray *allPONumberObjects =  [self getOrderData];
    if ([allPONumberObjects count] > 0) {
        self.orderDataObjectsForPoNumbers = allPONumberObjects;
        
        NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
        self.flaggedPONumbers = [[NSMutableDictionary alloc]init];
        self.poAndDateDictionary = [[NSMutableDictionary alloc]init];
        self.poAndIndexDictionary = [[NSMutableDictionary alloc] init];
        self.poAndScoreDictionary = [[NSMutableDictionary alloc] init];
        
        for (OrderData *orderData in self.orderDataObjectsForPoNumbers) {
            [poNumbersMutableSet addObject:orderData.PONumber];
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            if([self.poAndDateDictionary objectForKey:orderData.PONumber] != nil){
                temp = [self.poAndDateDictionary objectForKey:orderData.PONumber];
            }
            if(![temp containsObject:orderData.ExpectedDeliveryDateTime])
                [temp addObject:orderData.ExpectedDeliveryDateTime];
            [self.poAndDateDictionary setObject:temp forKey:orderData.PONumber];
            int index = 0;
            [self.poAndIndexDictionary setObject:[NSNumber numberWithInteger:index] forKey:orderData.PONumber];
            NSMutableArray *poScore = [[NSMutableArray alloc] init];
            if([self.poAndScoreDictionary objectForKey:orderData.PONumber] != nil){
                poScore = [self.poAndScoreDictionary objectForKey:orderData.PONumber];
            }
            if(orderData.score != nil)
                [poScore addObject:orderData.score];
            [self.poAndScoreDictionary setObject:poScore forKey:orderData.PONumber];
            
            //build up an array of flagged PONumbers to highlight
            if(orderData.FlaggedProduct){
                // [self.flaggedPONumbers addObject:orderData.PONumber];
                [self.flaggedPONumbers setObject:orderData.Message forKey:orderData.PONumber];
            }else{
                NSArray* orderDataFromDB =  [[Inspection sharedInspection] getOrderData];
                for(OrderData *order in orderDataFromDB){
                    if([order.PONumber isEqualToString:orderData.PONumber]){
                        if(order.FlaggedProduct){
                            [self.flaggedPONumbers setObject:order.Message forKey:order.PONumber];
                            break;
                        }
                    }
                }
            }
        }
        self.poNumbersArray = [poNumbersMutableSet allObjects];
        //self.poNumbersArray = [self.poNumbersArray sortedArrayUsingSelector: @selector(compare:)];
        [self.comboItemsGlobal addObjectsFromArray:self.poNumbersArray];
        self.comboItemsGlobal = [self.poNumbersArray mutableCopy];
    }
}
- (void) getGRNsAndFilterThem {
    NSArray *allGRNObjects =  [self getOrderDataForGRN];
    if ([allGRNObjects count] > 0) {
        self.orderDataObjectsForGRN = allGRNObjects;
        
        NSMutableSet *grnMutableSet = [NSMutableSet set];
        self.flaggedGRNs = [[NSMutableDictionary alloc]init];
        self.grnAndDateDictionary = [[NSMutableDictionary alloc]init];
        self.grnAndIndexDictionary = [[NSMutableDictionary alloc] init];
        self.grnAndScoreDictionary = [[NSMutableDictionary alloc] init];
        
        for (OrderData *orderData in self.orderDataObjectsForGRN) {
            [grnMutableSet addObject:orderData.grn];
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            if([self.grnAndDateDictionary objectForKey:orderData.grn] != nil){
                temp = [self.grnAndDateDictionary objectForKey:orderData.grn];
            }
            if(![temp containsObject:orderData.ExpectedDeliveryDateTime])
                [temp addObject:orderData.ExpectedDeliveryDateTime];
            [self.grnAndDateDictionary setObject:temp forKey:orderData.grn];
            int index = 0;
            [self.grnAndIndexDictionary setObject:[NSNumber numberWithInteger:index] forKey:orderData.grn];
            NSMutableArray *grnScore = [[NSMutableArray alloc] init];
            if([self.grnAndScoreDictionary objectForKey:orderData.grn] != nil){
                grnScore = [self.grnAndScoreDictionary objectForKey:orderData.grn];
            }
            if(orderData.score != nil)
                [grnScore addObject:orderData.score];
            [self.grnAndScoreDictionary setObject:grnScore forKey:orderData.grn];
            
            //build up an array of flagged PONumbers to highlight
            if(orderData.FlaggedProduct){
                // [self.flaggedPONumbers addObject:orderData.PONumber];
                [self.flaggedGRNs setObject:orderData.Message forKey:orderData.grn];
            }else{
                NSArray* orderDataFromDB =  [[Inspection sharedInspection] getOrderData];
                for(OrderData *order in orderDataFromDB){
                    if([order.grn isEqualToString:orderData.grn] ){
                        if(order.FlaggedProduct){
                            [self.flaggedGRNs setObject:order.Message forKey:order.grn];
                            break;
                        }
                    }
                }
            }
        }
        self.grnArray = [grnMutableSet allObjects];
        //self.poNumbersArray = [self.poNumbersArray sortedArrayUsingSelector: @selector(compare:)];
        [self.comboItemsGlobal addObjectsFromArray:self.grnArray];
        self.comboItemsGlobal = [self.grnArray mutableCopy];
    }
}

-(NSArray*)getOrderDataForGRN{
    if(self.orderDataObjectsForGRN && [self.orderDataObjectsForGRN count]>0)
        return [self.orderDataObjectsForGRN copy];
    
    NSArray* orderDataFromDB =  [[Inspection sharedInspection] getOrderData];
    NSMutableArray* orderDataFilteredForBlankValues = [[NSMutableArray alloc]init];
    BOOL isDispatchInspectionContainer = NO;
    BOOL isReceivingInspectionContainer = NO;
    if([[self delegate] isContainerRatingPresentWithOrderDataField:@"vendorname"])
        isReceivingInspectionContainer = YES;
    if([[self delegate] isContainerRatingPresentWithOrderDataField:@"customername"])
        isDispatchInspectionContainer = YES;
    
    for(OrderData* orderdata in orderDataFromDB){
        if(isDispatchInspectionContainer && (!orderdata.CustomerName || [orderdata.CustomerName isEqualToString:@""]))
            continue; //if dispatch container - remove all the rows with blank customer names
        else if(isReceivingInspectionContainer && (!orderdata.VendorName || [orderdata.VendorName isEqualToString:@""]))
            continue;//if receiving container - remove all the rows with blank vendor names
        
        [orderDataFilteredForBlankValues addObject:orderdata];
    }
    orderDataFromDB = [orderDataFilteredForBlankValues copy];
    
    NSMutableArray* orderDataSortedByDateAndGRN = [[NSMutableArray alloc]init];
    [orderDataSortedByDateAndGRN addObjectsFromArray:orderDataFromDB];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"ExpectedDeliveryDateTime" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"grn" ascending:YES];
    [orderDataSortedByDateAndGRN sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
    int count = 0;
    while(count < 2){
    for(int i = 0; i < orderDataSortedByDateAndGRN.count; i++){
        OrderData *orderTemp = [orderDataSortedByDateAndGRN objectAtIndex:i];
        for(int j = i + 1; j < orderDataSortedByDateAndGRN.count;j++){
            OrderData *orderTemp2 = [orderDataSortedByDateAndGRN objectAtIndex:j];
            if(orderTemp.grn == orderTemp2.grn){
                NSString *date1 = orderTemp.ExpectedDeliveryDateTime;
                NSString *date2 = orderTemp2.ExpectedDeliveryDateTime;
                if([date1 isEqualToString:date2]){
                    [orderDataSortedByDateAndGRN removeObjectAtIndex:j];
                    j = i + 1;
                }
            }
        }
    }
        count++;
    }
    self.orderDataObjectsForGRN = orderDataSortedByDateAndGRN;
    return self.orderDataObjectsForGRN;
}
-(NSArray*)getOrderData{
    if(self.orderDataObjectsForPoNumbers && [self.orderDataObjectsForPoNumbers count]>0)
        return [self.orderDataObjectsForPoNumbers copy];
    
    NSArray* orderDataFromDB =  [[Inspection sharedInspection] getOrderData];
    NSMutableArray* orderDataFilteredForBlankValues = [[NSMutableArray alloc]init];
    BOOL isDispatchInspectionContainer = NO;
    BOOL isReceivingInspectionContainer = NO;
    if([[self delegate] isContainerRatingPresentWithOrderDataField:@"vendorname"])
        isReceivingInspectionContainer = YES;
    if([[self delegate] isContainerRatingPresentWithOrderDataField:@"customername"])
        isDispatchInspectionContainer = YES;
    
    for(OrderData* orderdata in orderDataFromDB){
        if(isDispatchInspectionContainer && (!orderdata.CustomerName || [orderdata.CustomerName isEqualToString:@""]))
            continue; //if dispatch container - remove all the rows with blank customer names
        else if(isReceivingInspectionContainer && (!orderdata.VendorName || [orderdata.VendorName isEqualToString:@""]))
            continue;//if receiving container - remove all the rows with blank vendor names
        
        [orderDataFilteredForBlankValues addObject:orderdata];
    }
    orderDataFromDB = [orderDataFilteredForBlankValues copy];
    
    /* NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"yyyy-MM-dd"];
     //TODO: use NSDescriptor
     self.orderDataObjectsForPoNumbers = [orderDataFromDB sortedArrayUsingComparator:^NSComparisonResult(OrderData *data1, OrderData *data2){
     // Convert string to date object
     NSDate *date1 = [dateFormat dateFromString:data1.ExpectedDeliveryDateTime];
     NSDate *date2 = [dateFormat dateFromString:data2.ExpectedDeliveryDateTime];
     return [date2 compare:date1];
     }];
     //DI-2740 - sort by PONumbers within each date group
     //self.orderDataObjectsForPoNumbers = [self sortPONumbersWithinEachDate:self.orderDataObjectsForPoNumbers];
     return [self.orderDataObjectsForPoNumbers copy];*/
    
    //DI-2740 - sort first by date and then by PONumbers within each date group
    NSMutableArray* orderDataSortedByDateAndPONumbers = [[NSMutableArray alloc]init];
    [orderDataSortedByDateAndPONumbers addObjectsFromArray:orderDataFromDB];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"ExpectedDeliveryDateTime" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"PONumber" ascending:YES];
    [orderDataSortedByDateAndPONumbers sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
    int count = 0;
    while(count < 2){
    for(int i = 0; i < orderDataSortedByDateAndPONumbers.count; i++){
        OrderData *orderTemp = [orderDataSortedByDateAndPONumbers objectAtIndex:i];
        for(int j = i + 1; j < orderDataSortedByDateAndPONumbers.count;j++){
            OrderData *orderTemp2 = [orderDataSortedByDateAndPONumbers objectAtIndex:j];
            if(orderTemp.PONumber == orderTemp2.PONumber){
                NSString *date1 = orderTemp.ExpectedDeliveryDateTime;
                NSString *date2 = orderTemp2.ExpectedDeliveryDateTime;
                if([date1 isEqualToString:date2]){
                    [orderDataSortedByDateAndPONumbers removeObjectAtIndex:j];
                    j = i + 1;
                }
            }
        }
    }
        count++;
    }
    self.orderDataObjectsForPoNumbers = orderDataSortedByDateAndPONumbers;
    return self.orderDataObjectsForPoNumbers;
}

/*
 -(NSArray*)sortPONumbersWithinEachDate:(NSArray*)orderDataSortedByDate {
 NSString* date;
 NSMutableArray* orderDataSortedByDateAndPONumbers = [[NSMutableArray alloc]init];
 NSMutableArray* orderDataSortedByPO = [[NSMutableArray alloc]init];
 for(OrderData *orderData in orderDataSortedByDate){
 if(!date || ![date isEqualToString:orderData.ExpectedDeliveryDateTime]){
 date = orderData.ExpectedDeliveryDateTime;
 [orderDataSortedByDateAndPONumbers addObjectsFromArray:orderDataSortedByPO];
 orderDataSortedByPO = [[NSMutableArray alloc]init];
 }
 if([date isEqualToString:orderData.ExpectedDeliveryDateTime]){
 [orderDataSortedByPO addObject:orderData];
 }
 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"PONumber" ascending:YES selector:@selector(compare:)];
 [orderDataSortedByPO sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
 }
 return [orderDataSortedByDateAndPONumbers copy];
 }
 */
- (void) getVendorNamesAndFilterThem {
    self.vendorAndScoreDictionary = [[NSMutableDictionary alloc] init];
    //NSArray *allVendorObjects =  [[Inspection sharedInspection] getOrderData];
    NSArray *allVendorObjects =  [self getOrderData];
    if ([allVendorObjects count] > 0) {
        self.orderDataObjectsForPoNumbers = allVendorObjects;
        NSMutableSet *vendorNamesMutableSet = [NSMutableSet set];
        self.flaggedSuppliers = [[NSMutableDictionary alloc]init];
        for (OrderData *orderData in self.orderDataObjectsForPoNumbers) {
            
            if (orderData.VendorName) {
                NSMutableArray *vendorScore = [[NSMutableArray alloc] init];
                if([self.vendorAndScoreDictionary objectForKey:orderData.VendorName] != nil){
                    vendorScore = [self.vendorAndScoreDictionary objectForKey:orderData.VendorName];
                }
                if(orderData.score != nil)
                    [vendorScore addObject:orderData.score];
                [self.vendorAndScoreDictionary setObject:vendorScore forKey:orderData.VendorName];
                [vendorNamesMutableSet addObject:orderData.VendorName];
                //build up an array of flagged suppliers to highlight
                if(orderData.FlaggedProduct){
                    //[self.flaggedSuppliers addObject:orderData.VendorName];
                    [self.flaggedSuppliers setObject:orderData.Message forKey:orderData.VendorName];
                }else{
                    NSArray* orderDataFromDB =  [[Inspection sharedInspection] getOrderData];
                    for(OrderData *order in orderDataFromDB){
                        if([order.VendorName isEqualToString:orderData.VendorName]){
                            if(order.FlaggedProduct){
                                [self.flaggedSuppliers setObject:order.Message forKey:order.VendorName];
                                break;
                            }
                        }
                    }
                }
            }
        }
        self.vendorNamesArray = [vendorNamesMutableSet allObjects];
        self.vendorNamesArray = [self.vendorNamesArray sortedArrayUsingSelector: @selector(compare:)];
        [self.comboItemsGlobal addObjectsFromArray:self.vendorNamesArray];
        self.comboItemsGlobal = [self.vendorNamesArray mutableCopy];
    }
}

- (void)refreshState
{
    [super refreshState];
    [self addAdditionalButtons];
    self.cellTitle = @"selectOptionButton";
    self.comboItemsForDates = [[NSMutableArray alloc] init];
    self.comboItems = [[NSMutableArray alloc] init];
    self.comboItemsGlobal = [[NSMutableArray alloc] init];
    NSString *orderDataField = self.rating.order_data_field;
    if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"]) {
        [self getPONumbersAndFilterThem];
    } else if ([[orderDataField lowercaseString] isEqualToString:@"vendorname"]) {
        [self getVendorNamesAndFilterThem];
    } else if ([[orderDataField lowercaseString] isEqualToString:@"loadid"]) {
        [self populateAllLoadIds];
    }else if ([[orderDataField lowercaseString] isEqualToString:@"customername"]) {
        [self populateCustomerName];
    }else if ([[orderDataField lowercaseString] isEqualToString:@"grn"]) {
        [self getGRNsAndFilterThem];
    }
    [self.comboItemsGlobal addObjectsFromArray:self.rating.content.comboRatingModel.comboItems];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUtilityButtonViewFromSuperView) name:@"RemoveUtilityView" object:nil];
    self.otherTextField.layer.borderWidth = 1.0;
    self.otherTextField.layer.borderColor = [[UIColor blackColor] CGColor];
    
    //Configure utilityButtonView
    
    self.utilityButtonView.hidden = YES;
    /* UIWindow *win = [[UIApplication sharedApplication] keyWindow];
     [win addSubview:utilityButtonView];
     
     utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 260.0), (win.bounds.size.width), 44.0);*/
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // utilityButtonView.frame = CGRectMake(0, (win.bounds.size.height - 304.0), win.bounds.size.width, 44.0);
        
        //hide the default assistant buttons on iPAD
        if ([self respondsToSelector:@selector(inputAssistantItem)]) {
            // iOS9.
            UITextInputAssistantItem* item = [self inputAssistantItem];
            item.leadingBarButtonGroups = @[];
            item.trailingBarButtonGroups = @[];
        }
    }
    
    /* self.utilityButtonView.barStyle = UIBarStyleBlack;
     self.utilityButtonView.translucent = YES;
     self.utilityButtonView.tintColor = nil;*/
    
    if (!fontsSet) {
        [self configureFonts];
    }
    if (self.rating.ratingAnswerFromUI && ![self.rating.ratingAnswerFromUI isEqualToString:@""]) {
        self.selectLabel.text = [NSString stringWithFormat:@"%@", self.rating.ratingAnswerFromUI];
    } else {
        self.selectLabel.text = [NSString stringWithFormat:@"Select Option"];
    }
    [self getPOsFilteredAndSorted];
    if (![self.rating.ratingAnswerFromUI isEqualToString:@""] && self.rating.ratingAnswerFromUI) {
        if (![self checkIfTheOptionIsNotOther:self.rating.ratingAnswerFromUI] || [self isOther:self.rating.ratingAnswerFromUI]) { //handle "OTHER"
            self.selectLabel.text = @"OTHER";
            self.otherTextField.hidden = NO;
            if([self isOther:self.rating.ratingAnswerFromUI]) //is "OTHER"
                self.otherTextField.text = @"";
            else
                self.otherTextField.text = self.rating.ratingAnswerFromUI;
        } else {
            self.selectLabel.text = self.rating.ratingAnswerFromUI;
            self.otherTextField.hidden = YES;
        }
    } else {
        self.otherTextField.hidden = YES;
        self.selectLabel.text = @"Select Option";
    }
    
    if (![[User sharedUser].userSelectedVendorName isEqualToString:@""] && [[self.rating.order_data_field lowercaseString] isEqualToString:@"vendorname"] && [User sharedUser].userSelectedVendorName) {
        self.selectLabel.text = [User sharedUser].userSelectedVendorName;
    }
    
    self.selectOptionButton.enabled = YES;
    
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneTap)];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearTap)];
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        doneButton.tintColor = [UIColor whiteColor];
        clearButton.tintColor = [UIColor whiteColor];
    }
    [utilityButtonView setItems:[NSArray arrayWithObjects:flex, clearButton, doneButton, nil]];
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(doneTap)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.otherTextField.inputAccessoryView = keyboardToolbar;
}

- (NSString *) autoSelectPOIfPresent {
    NSString *orderDataField = self.rating.order_data_field;
    NSMutableArray *comboItemsArray = [[NSMutableArray alloc] init];
    if ([[orderDataField lowercaseString] isEqualToString:@"vendorname"]) {
        [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjects] copy]];
        if ([comboItemsArray count] == 1) {
            return [comboItemsArray objectAtIndex:0];
        }
    }
    return @"";
}
- (NSString *) autoSelectGRNIfPresent {
    NSString *orderDataField = self.rating.order_data_field;
    NSMutableArray *comboItemsArray = [[NSMutableArray alloc] init];
    if ([[orderDataField lowercaseString] isEqualToString:@"vendorname"]) {
        [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByGRN] copy]];
        if ([comboItemsArray count] == 1) {
            return [comboItemsArray objectAtIndex:0];
        }
    }
    return @"";
}
- (NSString *) autoSelectVendorIfPresent {
    NSString *orderDataField = self.rating.order_data_field;
    NSMutableArray *comboItemsArray = [[NSMutableArray alloc] init];
    if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"]) {
        [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByPO] copy]];
        if ([comboItemsArray count] > 0) {
            return [comboItemsArray objectAtIndex:0];
        }
    } else if ([[orderDataField lowercaseString] isEqualToString:@"grn"]) {
        [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByGRNs] copy]];
        if ([comboItemsArray count] > 0) {
            return [comboItemsArray objectAtIndex:0];
        }
    }
    return @"";
}

- (NSString *) autoSelectPOIfPresentForCustomer {
    NSString *orderDataField = self.rating.order_data_field;
    NSMutableArray *comboItemsArray = [[NSMutableArray alloc] init];
    if ([[orderDataField lowercaseString] isEqualToString:@"customername"]) {
        // [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByPOForCustomerName] copy]];
        NSString* customerName = [self getSelectedCustomerName];
        [comboItemsArray removeAllObjects];
        [comboItemsArray addObjectsFromArray: [self filterPOByCustomerName:customerName]];
        if ([comboItemsArray count] == 1) {
            return [comboItemsArray objectAtIndex:0];
        }
    }
    return @"";
}

- (BOOL) checkIfTheOptionIsNotOther: (NSString *) option {
    BOOL notOther = NO;
    NSArray *combo = self.comboItems;
    for (NSString *optionLocal in combo) {
        if ([optionLocal isEqualToString:option]) {
            notOther = YES;
            break;
        }
    }
    return notOther;
}

- (NSArray *) filterOrderDataObjectsByPO {
    //NSArray *allPONumberObjects = [[Inspection sharedInspection] getOrderData];
    NSArray *allPONumberObjects = [self getOrderData];
    NSMutableArray *filteredPOForVendorNames = [NSMutableArray array];
    //NSLog(@"%@", [User sharedUser].temporaryPONumberFromUserClass);
    if ([[User sharedUser] temporaryPONumberFromUserClass] && ![[[User sharedUser] temporaryPONumberFromUserClass] isEqualToString:@""]) {
        for (OrderData *orderData in allPONumberObjects) {
            if ([orderData.PONumber isEqualToString:[[User sharedUser] temporaryPONumberFromUserClass]]) {
                [filteredPOForVendorNames addObject:orderData];
            }
        }
    }
    if ([filteredPOForVendorNames count] == 0  ) {
        filteredPOForVendorNames = [allPONumberObjects copy];
    }
    if ([filteredPOForVendorNames count] > 0) {
        NSMutableSet *vendorNamesMutableSet = [NSMutableSet set];
        for (OrderData *orderData in filteredPOForVendorNames) {
            if(!orderData.VendorName)
                continue;
            [vendorNamesMutableSet addObject:orderData.VendorName];
            //NSLog(@"%@", orderData.VendorName);
        }
        self.vendorNamesFilteredArray = [vendorNamesMutableSet allObjects];
        self.vendorNamesFilteredArray = [self.vendorNamesFilteredArray sortedArrayUsingSelector: @selector(compare:)];
    }
    return self.vendorNamesFilteredArray;
}
- (NSArray *) filterOrderDataObjectsByGRNs {
    //NSArray *allPONumberObjects = [[Inspection sharedInspection] getOrderData];
    NSArray *allPONumberObjects = [self getOrderDataForGRN];
    NSMutableArray *filteredPOForVendorNames = [NSMutableArray array];
    //NSLog(@"%@", [User sharedUser].temporaryPONumberFromUserClass);
    if ([[User sharedUser] temporaryGRNFromUserClass] && ![[[User sharedUser] temporaryGRNFromUserClass] isEqualToString:@""]) {
        for (OrderData *orderData in allPONumberObjects) {
            if ([orderData.grn isEqualToString:[[User sharedUser] temporaryGRNFromUserClass]]) {
                [filteredPOForVendorNames addObject:orderData];
            }
        }
    }
    if ([filteredPOForVendorNames count] == 0  ) {
        filteredPOForVendorNames = [allPONumberObjects copy];
    }
    if ([filteredPOForVendorNames count] > 0) {
        NSMutableSet *vendorNamesMutableSet = [NSMutableSet set];
        for (OrderData *orderData in filteredPOForVendorNames) {
            if(!orderData.VendorName)
                continue;
            [vendorNamesMutableSet addObject:orderData.VendorName];
            //NSLog(@"%@", orderData.VendorName);
        }
        self.vendorNamesFilteredArray = [vendorNamesMutableSet allObjects];
        self.vendorNamesFilteredArray = [self.vendorNamesFilteredArray sortedArrayUsingSelector: @selector(compare:)];
    }
    return self.vendorNamesFilteredArray;
}
- (NSArray *) filterOrderDataObjectsByPOForCustomerName {
    NSArray *allPONumberObjects = [self getOrderData];
    NSMutableArray *filteredPOForVendorNames = [NSMutableArray array];
    NSString* selectedCustomerName =[[User sharedUser] userSelectedCustomerName];
    if  (selectedCustomerName && ![selectedCustomerName isEqualToString:@""]) {
        for (OrderData *orderData in allPONumberObjects) {
            if ([orderData.CustomerName isEqualToString:selectedCustomerName]) {
                [filteredPOForVendorNames addObject:orderData];
            }
        }
    }
    if ([filteredPOForVendorNames count] == 0  ) {
        filteredPOForVendorNames = [allPONumberObjects copy];
    }
    if ([filteredPOForVendorNames count] > 0) {
        NSMutableSet *vendorNamesMutableSet = [NSMutableSet set];
        for (OrderData *orderData in filteredPOForVendorNames) {
            if(!orderData.CustomerName)
                continue;
            [vendorNamesMutableSet addObject:orderData.CustomerName];
        }
        self.vendorNamesFilteredArray = [vendorNamesMutableSet allObjects];
        self.vendorNamesFilteredArray = [self.vendorNamesFilteredArray sortedArrayUsingSelector: @selector(compare:)];
    }
    return self.vendorNamesFilteredArray;
}
- (NSArray *) filterOrderDataObjectsByGRNForCustomerName {
    
    NSArray *allGRNNumberObjects = [self getOrderDataForGRN];
    NSMutableArray *filteredGRNForVendorNames = [NSMutableArray array];
    NSString* selectedCustomerName =[[User sharedUser] userSelectedCustomerName];
    if  (selectedCustomerName && ![selectedCustomerName isEqualToString:@""]) {
        for (OrderData *orderData in allGRNNumberObjects) {
            if ([orderData.CustomerName isEqualToString:selectedCustomerName]) {
                [filteredGRNForVendorNames addObject:orderData];
            }
        }
    }
    if ([filteredGRNForVendorNames count] == 0  ) {
        filteredGRNForVendorNames = [allGRNNumberObjects copy];
    }
    if ([filteredGRNForVendorNames count] > 0) {
        NSMutableSet *vendorNamesMutableSet = [NSMutableSet set];
        for (OrderData *orderData in filteredGRNForVendorNames) {
            if(!orderData.CustomerName)
                continue;
            [vendorNamesMutableSet addObject:orderData.CustomerName];
        }
        self.vendorNamesFilteredArray = [vendorNamesMutableSet allObjects];
        self.vendorNamesFilteredArray = [self.vendorNamesFilteredArray sortedArrayUsingSelector: @selector(compare:)];
    }
    return self.vendorNamesFilteredArray;
}

#pragma mark CustomerName filtering

-(NSString*)getSelectedCustomerName {
    NSString* selectedCustomerName = [User sharedUser].userSelectedCustomerName;
    return selectedCustomerName;
}

-(void)setCustomerName:(NSString*)CustomerName {
    [User sharedUser].userSelectedCustomerName = CustomerName;
}

-(BOOL) isCustomerNameSet {
    NSString* CustomerName = [self getSelectedCustomerName];
    if(CustomerName && ![CustomerName isEqualToString:@""] &&
       ![self isOther:CustomerName] &&
       ![[CustomerName lowercaseString] isEqualToString:@"none"])
        return YES;
    
    return NO;
}

-(void)populateCustomerName {
    self.customerAndScoreDictionary = [[NSMutableDictionary alloc] init];
    NSArray *allCustomerNames =  [self getOrderData];
    allCustomerNames = [self sortOrderData:allCustomerNames byKey:@"CustomerName" isAscending:YES];
    if ([allCustomerNames count] > 0) {
        NSMutableArray *mutableSet = [[NSMutableArray alloc]init];
        for (OrderData *orderData in allCustomerNames) {
            if(!orderData.CustomerName)
                continue;
            if(![mutableSet containsObject:orderData.CustomerName])
            {
                NSMutableArray *customerScore = [[NSMutableArray alloc] init];
                if([self.customerAndScoreDictionary objectForKey:orderData.CustomerName] != nil){
                    customerScore = [self.customerAndScoreDictionary objectForKey:orderData.CustomerName];
                }
                if(orderData.score != nil)
                    [customerScore addObject:orderData.score];
                [self.customerAndScoreDictionary setObject:customerScore forKey:orderData.CustomerName];
                [mutableSet addObject:orderData.CustomerName];
            }
        }
        NSArray* allCustomerNamesList = [mutableSet copy];
        [self.comboItemsGlobal addObjectsFromArray:allCustomerNamesList];
        self.comboItemsGlobal = [allCustomerNamesList mutableCopy];
    }
}

-(NSArray*) filterCustomerNameByPO:(NSString*)po {
    NSArray *allOrderData = [self getOrderData];
    NSMutableSet *customersMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.PONumber isEqualToString:po]) {
            if(!orderData.CustomerName)
                continue;
            [customersMutableSet addObject:orderData.CustomerName];
        }
    }
    NSArray *array = [customersMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return array;
}
-(NSArray*) filterCustomerNameByGRN:(NSString*)grn {
    NSArray *allOrderData = [self getOrderDataForGRN];
    NSMutableSet *customersMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.grn isEqualToString:grn]) {
            if(!orderData.CustomerName)
                continue;
            [customersMutableSet addObject:orderData.CustomerName];
        }
    }
    NSArray *array = [customersMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return array;
}
-(NSArray*) filterPOByCustomerName:(NSString*)customerName {
    NSArray *allOrderData = [self getOrderData];
    NSMutableSet *poMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.CustomerName isEqualToString:customerName]) {
            [poMutableSet addObject:orderData.PONumber];
        }
    }
    NSArray *array = [poMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.poNumbersArray = array;
    return array;
}
-(NSArray*) filterGRNByCustomerName:(NSString*)customerName {
    NSArray *allOrderData = [self getOrderData];
    NSMutableSet *poMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.CustomerName isEqualToString:customerName]) {
            [poMutableSet addObject:orderData.grn];
        }
    }
    NSArray *array = [poMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.poNumbersArray = array;
    return array;
}
//update loadId based on selected supplier/PO
-(void)updateCustomerNameForPO:(NSString*)poNumber {
    if([self isCustomerNameSet])
        return;
    NSArray* customerNames = [self filterCustomerNameByPO:poNumber];
    if(customerNames && [customerNames count]==1){
        NSString* customerName = [customerNames objectAtIndex:0];
        [self setCustomerName:customerName];
        [[self delegate] setOrderDataComboRatingValue:customerName withOrderDataKey:@"customername"];
        self.rating.ratingAnswerFromUI = customerName;
    }
    
    [[self delegate] refreshTheView];
}
-(void)updateCustomerNameForGRN:(NSString*)grn {
    if([self isCustomerNameSet])
        return;
    NSArray* customerNames = [self filterCustomerNameByGRN:grn];
    if(customerNames && [customerNames count]==1){
        NSString* customerName = [customerNames objectAtIndex:0];
        [self setCustomerName:customerName];
        [[self delegate] setOrderDataComboRatingValue:customerName withOrderDataKey:@"customername"];
        self.rating.ratingAnswerFromUI = customerName;
    }
    
    [[self delegate] refreshTheView];
}
#pragma mark LoadId filtering

-(NSString*)getSelectedLoadId {
    NSString* selectedLoadId = [User sharedUser].userSelectedLoadId;
    return selectedLoadId;
}

-(void)setLoadId:(NSString*)loadId {
    [User sharedUser].userSelectedLoadId = loadId;
}

-(BOOL) isLoadIdSet {
    NSString* loadId = [self getSelectedLoadId];
    if(loadId && ![loadId isEqualToString:@""] &&
       ![self isOther:loadId] &&
       ![[loadId lowercaseString] isEqualToString:@"none"])
        return YES;
    
    return NO;
}

-(BOOL) isSupplierSet {
    NSString* supplier =  [User sharedUser].userSelectedVendorName;
    if(supplier && ![supplier isEqualToString:@""] && ![self isOther:supplier] && ![[supplier lowercaseString] isEqualToString:@"none"])
        return YES;
    
    return NO;
}



-(void)populateAllLoadIds {
    NSArray *allLoadIds =  [self getOrderData];
    allLoadIds = [self sortOrderData:allLoadIds byKey:@"loadId" isAscending:YES];
    if ([allLoadIds count] > 0) {
        NSMutableArray *loadIdMutableSet = [[NSMutableArray alloc]init];
        for (OrderData *orderData in allLoadIds) {
            if(![loadIdMutableSet containsObject:orderData.loadId])
                [loadIdMutableSet addObject:orderData.loadId];
        }
        self.loadIdArray = [loadIdMutableSet copy];
        
        [self.comboItemsGlobal addObjectsFromArray:self.loadIdArray];
        self.comboItemsGlobal = [self.loadIdArray mutableCopy];
    }
}

-(NSArray*) filterPOByLoadId:(NSString*)loadId {
    NSArray *allOrderData = [self getOrderData];
    NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.loadId isEqualToString:loadId]) {
            [poNumbersMutableSet addObject:orderData.PONumber];
        }
    }
    NSArray *array = [poNumbersMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return array;
}

-(NSArray*) filterPOByLoadId:(NSString*)loadId withVendor:(NSString*)vendor {
    NSArray *allOrderData = [self getOrderData];
    NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.loadId isEqualToString:loadId]
            &&[orderData.VendorName isEqualToString:vendor] ) {
            [poNumbersMutableSet addObject:orderData.PONumber];
        }
    }
    NSArray *array = [poNumbersMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [poNumbersMutableSet allObjects];
}
-(NSArray*) filterGRNByLoadId:(NSString*)loadId {
    NSArray *allOrderData = [self getOrderData];
    NSMutableSet *grnMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.loadId isEqualToString:loadId]) {
            [grnMutableSet addObject:orderData.grn];
        }
    }
    NSArray *array = [grnMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return array;
}

-(NSArray*) filterGRNByLoadId:(NSString*)loadId withVendor:(NSString*)vendor {
    NSArray *allOrderData = [self getOrderData];
    NSMutableSet *grnMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.loadId isEqualToString:loadId]
            &&[orderData.VendorName isEqualToString:vendor] ) {
            [grnMutableSet addObject:orderData.grn];
        }
    }
    NSArray *array = [grnMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [grnMutableSet allObjects];
}
-(NSArray*)filterVendorByLoadId:(NSString*)loadId {
    NSArray *allPONumberObjects = [self getOrderData];
    NSMutableSet *vendorMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allPONumberObjects) {
        if ([orderData.loadId isEqualToString:loadId]) {
            [vendorMutableSet addObject:orderData.VendorName];
        }
    }
    NSArray *array = [vendorMutableSet allObjects];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return array;
}
//update loadId based on selected supplier/PO
-(void)updateLoadIdWithSupplier:(NSString*)supplier withPO:(NSString*)poNumber {
    if([self isLoadIdSet])
        return;
    NSString* loadId = [self getLoadIdBySupplier:supplier withPO:poNumber];
    [self setLoadId:loadId];
    [[self delegate] setOrderDataComboRatingValue:loadId withOrderDataKey:@"loadid"];
}

-(void)updateLoadIdWithSupplier:(NSString*)supplier withGRN:(NSString*)grn {
    if([self isLoadIdSet])
        return;
    NSString* loadId = [self getLoadIdBySupplier:supplier withGRN:grn];
    [self setLoadId:loadId];
    [[self delegate] setOrderDataComboRatingValue:loadId withOrderDataKey:@"loadid"];
}

-(NSString*)getLoadIdBySupplier:(NSString*)supplier withGRN:(NSString*)grn {
    NSString* loadId = @"";
    NSArray *allPONumberObjects = [self getOrderDataForGRN];
    for (OrderData *orderData in allPONumberObjects) {
        if ([orderData.VendorName isEqualToString:supplier] &&
            [orderData.grn isEqualToString:grn]) {
            loadId = orderData.loadId;
        }
    }
    return loadId;
}

-(NSString*)getLoadIdBySupplier:(NSString*)supplier withPO:(NSString*)poNumber {
    NSString* loadId = @"";
    NSArray *allPONumberObjects = [self getOrderData];
    for (OrderData *orderData in allPONumberObjects) {
        if ([orderData.VendorName isEqualToString:supplier] &&
            [orderData.PONumber isEqualToString:poNumber]) {
            loadId = orderData.loadId;
        }
    }
    return loadId;
}

-(NSMutableArray*)getPOBySupplier:(NSString*)supplier withLoadId:(NSString*)loadId {
    NSMutableArray* filteredOrderData = [[NSMutableArray alloc]init];
    NSArray *allPONumberObjects = [self getOrderData];
    for (OrderData *orderData in allPONumberObjects) {
        if ([orderData.VendorName isEqualToString:supplier] &&
            [orderData.loadId isEqualToString:loadId]) {
            [filteredOrderData addObject:orderData.PONumber];
        }
    }
    return filteredOrderData;
}


-(NSArray*) sortOrderData:(NSArray*)orderData byKey:(NSString*)key isAscending:(BOOL)ascending {
    NSMutableArray* sortedOrderData = [[NSMutableArray alloc]init];
    [sortedOrderData addObjectsFromArray:orderData];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    [sortedOrderData sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
    return sortedOrderData;
}

- (void) removeUtilityButtonViewFromSuperView {
    self.utilityButtonView.hidden = YES;
    [self.otherTextField resignFirstResponder];
}

- (void) scannableButtonTouched {
    BOOL isCodeExplorer = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveUtilityView" object:self];
    //if codeexplorer show iNigma scanner
    //  if(isCodeExplorer) {
    ViewController *scannerViewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil withDelegate:self];
    [scannerViewController startScanner];//fire scanner after variables set
    if (self.myTableViewController.navigationController) {
        [self.myTableViewController.navigationController pushViewController:scannerViewController animated:YES];
    } else {
        id appDelegate = [[UIApplication sharedApplication] delegate];
        AppDelegate *appDel = (AppDelegate *)appDelegate;
        [appDel.navigationController pushViewController:scannerViewController animated:YES];
    }
    //  }
    /* else {  //if insights show RedLaserSDK
     self.pickerController = [[SWBarcodePickerManager sharedSWBarcodePickerManager] pickerController:self withScanOnly:YES];
     if (self.myTableViewController.navigationController) {
     [self.myTableViewController.navigationController pushViewController:self.pickerController animated:YES];
     } else {
     id appDelegate = [[UIApplication sharedApplication] delegate];
     AppDelegate *appDel = (AppDelegate *)appDelegate;
     [appDel.navigationController pushViewController:self.pickerController animated:YES];
     }
     }*/
    
}

#pragma mark - SWBarcodePickerManagerProtocol


- (void)scanDoneWithUpc:(NSString*)theUpc {
    //    if (self.myTableViewController.navigationController) {
    //        [self.myTableViewController.navigationController popViewControllerAnimated:YES];
    //    } else {
    //        id appDelegate = [[UIApplication sharedApplication] delegate];
    //        AppDelegate *appDel = (AppDelegate *)appDelegate;
    //        [appDel.navigationController popViewControllerAnimated:YES];
    //    }
    self.selectLabel.text = theUpc;
}

- (void)scanCheckingForProductOnServer:(Product*)productInProgress {
}

- (void)scanDoneWithProduct:(Product*)theProduct {
}

- (void)scanDoneWithError:(NSError*)theError forProduct:(Product*)theProduct {
}

- (void)scanCancelled {
}

- (BOOL)validate
{
    return [super validate];
}

- (NSString*)theAnswerAsString
{
    NSString *theAnswer = @"";
    if ([[self.selectLabel.text lowercaseString] isEqualToString:@"other"]) {
        [[Inspection sharedInspection] saveOtherToInspection:YES];
        [[Inspection sharedInspection] checkForOtherAndSaveItInUserDefaults: YES];
        NSString *otherString = self.otherTextField.text;
        if (![otherString isEqualToString:@""]) {
            [self saveNonOrderDataValues:otherString];
            return otherString;
        } else {
            return @"";
        }
    } else {
        //[[Inspection sharedInspection] saveOtherToInspection:NO];
        [[Inspection sharedInspection] checkForOtherAndSaveItInUserDefaults: NO];
        [self saveNonOrderDataValues:@""];
    }
    
    NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
    [optionsArray addObjectsFromArray:self.comboItems];
    for (int i = 0; i < [optionsArray count]; i++) {
        if (self.selectLabel && [self.selectLabel.text isEqualToString:[optionsArray objectAtIndex:i]]) {
            theAnswer = [NSString stringWithFormat:@"%@", [optionsArray objectAtIndex:i]];
        }
    }
    
    //DI-1831 - default option - should behave as selecting 'None' - as the earlier implementation was based on having a 'None' in options
    if([self isPODefaultOption:theAnswer])
    {
        NSLog(@"PO is selected as Default - setting to None");
        NSString* poNumber = @"None";
        [User sharedUser].temporaryPONumberFromUserClass = poNumber;
        [[Inspection sharedInspection] savePONumberToInspection:poNumber];
        return @"None";
    }
    if([self isGRNDefaultOption:theAnswer])
    {
        NSLog(@"PO is selected as Default - setting to None");
        NSString* poNumber = @"None";
        [User sharedUser].temporaryGRNFromUserClass = poNumber;
        [[Inspection sharedInspection] saveGRNToInspection:poNumber];
        return @"None";
    }
    if([self isSupplierDefaultOption:theAnswer]){
        NSLog(@"Supplier is selected as Default - setting to None");
        NSString *dcName = @"None";
        [User sharedUser].userSelectedVendorName = dcName;
        self.selectLabel.text = dcName;
        [NSUserDefaultsManager saveObjectToUserDefaults:dcName withKey:VendorNameSelected];
        return @"None";
    }
    return theAnswer;
}

-(void)saveNonOrderDataValues:(NSString*)value {
    ProductRatingViewController *productRatingViewController = (ProductRatingViewController *)self.myTableViewController;
    if ([productRatingViewController.parentView isEqualToString:defineContainerViewController] && [self.rating.order_data_field isEqualToString:@"VendorName"]) {
        [[Inspection sharedInspection] saveSupplierForNonOrderDataInspection:value];
    }
    if ([productRatingViewController.parentView isEqualToString:defineContainerViewController] && [[self.rating.order_data_field lowercaseString] isEqualToString:@"ponumber"]) {
        [[Inspection sharedInspection]savePOForNonOrderDataInspection:value];
    }
}

-(BOOL)isPODefaultOption:(NSString*)theAnswer{
    NSString *orderDataField = self.rating.order_data_field;
    if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"]
        && self.rating.optionalSettings.optional
        && [theAnswer isEqualToString:@""]
        && ![Inspection sharedInspection].isOtherSelected)
        return YES;
    
    return NO;
}
-(BOOL)isGRNDefaultOption:(NSString*)theAnswer{
    NSString *orderDataField = self.rating.order_data_field;
    if ([[orderDataField lowercaseString] isEqualToString:@"grn"]
        && self.rating.optionalSettings.optional
        && [theAnswer isEqualToString:@""]
        && ![Inspection sharedInspection].isOtherSelected)
        return YES;
    
    return NO;
}
-(BOOL)isSupplierDefaultOption:(NSString*)theAnswer{
    NSString *orderDataField = self.rating.order_data_field;
    if (([[orderDataField lowercaseString] isEqualToString:@"vendorname"])
        && self.rating.optionalSettings.optional
        && [theAnswer isEqualToString:@""]
        && ![Inspection sharedInspection].isOtherSelected)
        return YES;
    
    return NO;
}

- (IBAction)bringTheOptions:(id)sender {
    if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[ProductRatingViewController class]]) {
        NSArray *comboItemsArray = [self getPOsFilteredAndSorted];
        [self selectOptions:comboItemsArray withTitle:@"  Select Option"];
    } else if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
        NSArray *comboItemsArray = [self getPOsFilteredAndSorted];
        [self selectOptions:comboItemsArray withTitle:@"  Select Option"];
    }
}

//when the rating reloads - it should show filtered or complete based on the other ratings present
- (NSArray *) getPOsFilteredAndSorted {
    NSMutableArray *comboItemsArray = [[NSMutableArray alloc] init];
    NSString *orderDataField = self.rating.order_data_field;
    if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"]) {
        if([self isLoadIdSet]){
            //if load id selected, filter by loadId
            NSString* loadId = [self getSelectedLoadId];
            [comboItemsArray addObjectsFromArray: [[self filterPOByLoadId:loadId] copy]];
            if([self isSupplierSet]){
                [comboItemsArray removeAllObjects];
                [comboItemsArray addObjectsFromArray: [self filterPOByLoadId:loadId withVendor:[User sharedUser].userSelectedVendorName]];
            }
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }else if([self isCustomerNameSet]){
            NSString* customerName = [self getSelectedCustomerName];
            [comboItemsArray removeAllObjects];
            [comboItemsArray addObjectsFromArray: [self filterPOByCustomerName:customerName]];
        }else{
            [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjects] copy]];
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }
    } else if ([[orderDataField lowercaseString] isEqualToString:@"vendorname"]) {
        if(self.delegate.poSelectedFirst){
            [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByPO] copy]];
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }else if(self.delegate.grnSelectedFirst){
            [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByGRNs] copy]];
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }else if([self isLoadIdSet]){
            //if load id selected, filter by loadId
            NSString* loadId = [self getSelectedLoadId];
            [comboItemsArray addObjectsFromArray: [[self filterVendorByLoadId:loadId] copy]];
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }
        else{
            comboItemsArray = self.comboItemsGlobal;
            if([comboItemsArray count]==0){
                NSArray *comb = self.rating.content.comboRatingModel.comboItems;
                [comboItemsArray addObjectsFromArray:comb];
            }
        }
    }else if ([[orderDataField lowercaseString] isEqualToString:@"customername"]) {
        if(self.delegate.poSelectedFirst){
            [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByPOForCustomerName] copy]];
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        } else if(self.delegate.grnSelectedFirst){
            [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByGRNForCustomerName] copy]];
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }
        else{
            comboItemsArray = self.comboItemsGlobal;
            if([comboItemsArray count]==0){
                NSArray *comb = self.rating.content.comboRatingModel.comboItems;
                [comboItemsArray addObjectsFromArray:comb];
            }
        }
    }else if ([[orderDataField lowercaseString] isEqualToString:@"grn"]) {
        if([self isLoadIdSet]){
            //if load id selected, filter by loadId
            NSString* loadId = [self getSelectedLoadId];
            [comboItemsArray addObjectsFromArray: [[self filterGRNByLoadId:loadId] copy]];
            if([self isSupplierSet]){
                [comboItemsArray removeAllObjects];
                [comboItemsArray addObjectsFromArray: [self filterGRNByLoadId:loadId withVendor:[User sharedUser].userSelectedVendorName]];
            }
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }else if([self isCustomerNameSet]){
            NSString* customerName = [self getSelectedCustomerName];
            [comboItemsArray removeAllObjects];
            [comboItemsArray addObjectsFromArray: [self filterGRNByCustomerName:customerName]];
        }else{
            [comboItemsArray addObjectsFromArray: [[self filterOrderDataObjectsByGRN] copy]];
            NSArray *comb = self.rating.content.comboRatingModel.comboItems;
            [comboItemsArray addObjectsFromArray:comb];
        }
    }else {
        comboItemsArray = self.comboItemsGlobal;
    }
    self.comboItems = [comboItemsArray copy];
    return comboItemsArray;
}

- (NSArray *) filterOrderDataObjects {
    //NSArray *allPONumberObjects = [[Inspection sharedInspection] getOrderData];
    NSArray *allPONumberObjects = [self getOrderData];
    NSMutableArray *filteredPOForVendorNames = [NSMutableArray array];
    //NSLog(@"%@", [User sharedUser].userSelectedVendorName);
    if ([[User sharedUser] userSelectedVendorName] && ![[[User sharedUser] userSelectedVendorName] isEqualToString:@""] &&!self.delegate.poSelectedFirst) {
        for (OrderData *orderData in allPONumberObjects) {
            if ([orderData.VendorName isEqualToString:[[User sharedUser] userSelectedVendorName]]) {
                [filteredPOForVendorNames addObject:orderData];
            }
        }
    }
    if ([filteredPOForVendorNames count] == 0 ) {
        filteredPOForVendorNames = [allPONumberObjects copy];
    }
    if ([filteredPOForVendorNames count] > 0) {
        NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
        NSMutableArray* poNumbersWithoutDuplicates = [[NSMutableArray alloc]init];
        for (OrderData *orderData in filteredPOForVendorNames) {
            //keep original sort by date
          //  if(![poNumbersWithoutDuplicates containsObject:orderData.PONumber])
                [poNumbersWithoutDuplicates addObject:orderData.PONumber];
            //[poNumbersMutableSet addObject:orderData.PONumber]; //dont use set as it does not maintain order
            //NSLog(@"%@", orderData.PONumber);
        }
        self.poNumbersArray = [poNumbersWithoutDuplicates copy]; //[poNumbersMutableSet allObjects];
        //NSLog(@"self.poNumbersArray is %@",self.poNumbersArray);
        //self.poNumbersArray = [self.poNumbersArray sortedArrayUsingSelector: @selector(compare:)];
    }
    return self.poNumbersArray;
}


- (NSArray *) filterOrderDataObjectsByGRN {
    //NSArray *allPONumberObjects = [[Inspection sharedInspection] getOrderData];
    NSArray *allPONumberObjects = [self getOrderDataForGRN];
    NSMutableArray *filteredPOForVendorNames = [NSMutableArray array];
    //NSLog(@"%@", [User sharedUser].userSelectedVendorName);
    if ([[User sharedUser] userSelectedVendorName] && ![[[User sharedUser] userSelectedVendorName] isEqualToString:@""] &&!self.delegate.grnSelectedFirst) {
        for (OrderData *orderData in allPONumberObjects) {
            if ([orderData.VendorName isEqualToString:[[User sharedUser] userSelectedVendorName]]) {
                [filteredPOForVendorNames addObject:orderData];
            }
        }
    }
    if ([filteredPOForVendorNames count] == 0 ) {
        filteredPOForVendorNames = [allPONumberObjects copy];
    }
    if ([filteredPOForVendorNames count] > 0) {
        NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
        NSMutableArray* poNumbersWithoutDuplicates = [[NSMutableArray alloc]init];
        for (OrderData *orderData in filteredPOForVendorNames) {
            //keep original sort by date
          //  if(![poNumbersWithoutDuplicates containsObject:orderData.PONumber])
                [poNumbersWithoutDuplicates addObject:orderData.grn];
            //[poNumbersMutableSet addObject:orderData.PONumber]; //dont use set as it does not maintain order
            //NSLog(@"%@", orderData.PONumber);
        }
        self.grnArray = [poNumbersWithoutDuplicates copy]; //[poNumbersMutableSet allObjects];
        //NSLog(@"self.poNumbersArray is %@",self.poNumbersArray);
        //self.poNumbersArray = [self.poNumbersArray sortedArrayUsingSelector: @selector(compare:)];
    }
    return self.grnArray;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.questionNumber - 1) inSection:0];
    //    [self.myTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.questionNumber - 1) inSection:0];
    CGRect rectInTableView = [self.myTableView rectForRowAtIndexPath:indexPath];
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    [self.myTableView scrollRectToVisible:CGRectMake(0, rectInTableView.origin.y + 100, self.myTableView.frame.size.width, self.myTableView.frame.size.height) animated:YES];
    
    NSInteger maxTitleLinesBeforeAdditionalOffet = 1;
    if ([UIScreen mainScreen].bounds.size.height > 480.0) {
        maxTitleLinesBeforeAdditionalOffet = 6;
    }
    
    if (self.theQuestion.numberOfLines > maxTitleLinesBeforeAdditionalOffet) {
        // Edge case for essays with long questions, scroll further to the answer itself
        if (self.myTableViewController &&
            [self.myTableViewController isKindOfClass:[ProductRatingViewController class]]) {
            
            NSInteger myStartingPos = [(ProductRatingViewController*)self.myTableViewController verticalStartingPositionForRow:(self.questionNumber - 1)];
            NSInteger additionalOffset = kQuestionLabelHeight * (self.theQuestion.numberOfLines - maxTitleLinesBeforeAdditionalOffet);
            [self.myTableView setContentOffset:CGPointMake(0, myStartingPos + additionalOffset) animated:YES];
        } else if (self.myTableViewController &&
            [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
            
            NSInteger myStartingPos = [(HPTCaseCodeViewController*)self.myTableViewController verticalStartingPositionForRow:(self.questionNumber - 1)];
            NSInteger additionalOffset = kQuestionLabelHeight * (self.theQuestion.numberOfLines - maxTitleLinesBeforeAdditionalOffet);
            [self.myTableView setContentOffset:CGPointMake(0, myStartingPos + additionalOffset) animated:YES];
        }
    }
    
    if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[ProductRatingViewController class]]) {
        [(ProductRatingViewController*)self.myTableViewController tellOtherQuestionsToCloseKeyboard:self.rating];
    } else if (self.myTableViewController &&
        [self.myTableViewController isKindOfClass:[HPTCaseCodeViewController class]]) {
        [(HPTCaseCodeViewController*)self.myTableViewController tellOtherQuestionsToCloseKeyboard:self.rating];
    }
    [self.myTableView setContentOffset:self.myTableView.contentOffset animated:NO];
    self.utilityButtonView.hidden = NO;
    
}


/*------------------------------------------------------------------------------
 METHOD: prepareForReuse
 
 PURPOSE:
 Reset the state of the cell to be used for a search result item.
 -----------------------------------------------------------------------------*/
- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void) selectOptions: (NSArray *) comboItemsLocal withTitle: (NSString *) title {
    CGFloat xWidth = self.myTableViewController.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([comboItemsLocal count] < 5) {
        int heightAfterCalculation = ([comboItemsLocal count]+1) * 60.0f; //+1 to accomodate the Other
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.myTableViewController.view.frame.size.height - yHeight)/2.0f;
    
    BOOL refreshButtonNeeded = NO;
    NSString *orderDataField = self.rating.order_data_field;
    if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"] ||
        [[orderDataField lowercaseString] isEqualToString:@"vendorname"] ||
        [[orderDataField lowercaseString] isEqualToString:@"loadid"] ||
        [[orderDataField lowercaseString] isEqualToString:@"customername"]) {
        refreshButtonNeeded= YES;
    }
    if ([self.comboItems count] > 1) {
        poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight) withTextField:YES isRefreshNeeded:refreshButtonNeeded];
    } else {
        poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    }
    
    [self.myTableViewController.view endEditing:YES]; //dismiss any keyboard thats open on the screen
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    poplistview.isNumeric = self.rating.is_numeric;
    
    [poplistview setTitle:title];
    [poplistview show];
}

- (void) selectOptionsDates: (NSArray *) comboItemsLocal withTitle: (NSString *) title {
    CGFloat xWidth = self.myTableViewController.view.frame.size.width - 20.0f;
    CGFloat yHeight = popupDefaultHeight;
    if ([comboItemsLocal count] < 5) {
        int heightAfterCalculation = [comboItemsLocal count] * 60.0f;
        heightAfterCalculation = heightAfterCalculation + 40;
        yHeight = heightAfterCalculation;
    }
    CGFloat yOffset = (self.myTableViewController.view.frame.size.height - yHeight)/2.0f;
    poplistviewDates = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight) withTextField:YES isRefreshNeeded:NO];
    poplistviewDates.delegate = self;
    poplistviewDates.datasource = self;
    poplistviewDates.listView.scrollEnabled = TRUE;
    [poplistviewDates setTitle:title];
    [poplistviewDates show];
}

- (void)closeKeyboardIfOpen
{
    if (!utilityButtonView.hidden) {
        self.utilityButtonView.hidden = YES;
        
        [self.otherTextField resignFirstResponder];
    }
}


- (void)passKeyboardIfOpen
{
    if (!utilityButtonView.hidden) {
        self.utilityButtonView.hidden = YES;
        
        [self.otherTextField nextResponder];
    }
}

- (void)clearTap
{
    self.otherTextField.text = @"";
}


- (void)doneTap
{
    self.utilityButtonView.hidden = YES;
    
    [self.otherTextField resignFirstResponder];
    
    if (validatedOnce) {
        [self validate];
    }
}

-(BOOL) isOther:(NSString*)value {
    if([value caseInsensitiveCompare:@"other"] == NSOrderedSame)
        return YES;
    
    return NO;
    
}

#pragma mark - UIPopoverListViewDataSource

  - (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"PopUpCell";
    //UITableViewCell *cell = [popoverListView.listView dequeueReusableCellWithIdentifier:identifier];
    //if(!cell){
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    //}
    
    if (popoverListView == self.poplistview) {
        NSString *item =[self.comboItems objectAtIndex:indexPath.row];
        //cell.textLabel.text = item;
        cell.textLabel.text = item;
        BOOL isDateRow = NO;
        //DI-1976 - show dates for PO numbers
        NSString *orderDataField = self.rating.order_data_field;
        double total = 0.0;
        double avg = 0.0;
        if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"]) {
            NSMutableArray *poScore = [[NSMutableArray alloc] init];
            poScore = [self.poAndScoreDictionary objectForKey:item];
            for(int i = 0; i < poScore.count; i++){
                total += [[poScore objectAtIndex:i] doubleValue];
            }
            avg = total/poScore.count;
        }else if([[orderDataField lowercaseString] isEqualToString:@"vendorname"]){
            NSMutableArray *vendorScore = [[NSMutableArray alloc] init];
            vendorScore = [self.vendorAndScoreDictionary objectForKey:item];
            for(int i = 0; i < vendorScore.count; i++){
                total += [[vendorScore objectAtIndex:i] doubleValue];
            }
            avg = total/vendorScore.count;
        }else if([[orderDataField lowercaseString] isEqualToString:@"customername"]){
            NSMutableArray *customerScore = [[NSMutableArray alloc] init];
            customerScore = [self.customerAndScoreDictionary objectForKey:item];
            
            for(int i = 0; i < customerScore.count; i++){
                total += [[customerScore objectAtIndex:i] doubleValue];
            }
            avg = total/customerScore.count;
        } else if ([[orderDataField lowercaseString] isEqualToString:@"grn"]) {
            NSMutableArray *poScore = [[NSMutableArray alloc] init];
            poScore = [self.grnAndScoreDictionary objectForKey:item];
            for(int i = 0; i < poScore.count; i++){
                total += [[poScore objectAtIndex:i] doubleValue];
            }
            avg = total/poScore.count;
        }
        
        if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"] /*&& ![item isEqualToString:@"Other"]*/
            && !([item caseInsensitiveCompare:@"other"] == NSOrderedSame)){
            //compare with previous and show date only if different
            NSString *previousPO = @"";// [self.comboItems objectAtIndex:indexPath.row-1];
            NSArray* previousPODate = [[NSArray alloc] init];// [self.poAndDateDictionary objectForKey:previousPO];
            if(indexPath.row>0){
                previousPO = [self.comboItems objectAtIndex:indexPath.row-1];
                previousPODate = [self.poAndDateDictionary objectForKey:previousPO];
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.poAndDateDictionary objectForKey:item];
            NSNumber *temp = [self.poAndIndexDictionary objectForKey:item];
            int index = [temp intValue];
            NSString* date = [dateArr objectAtIndex:index];
            //use custom label
            UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.bounds.size.width, 20)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                textLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, self.bounds.size.width, 20)];
            }
            cell.textLabel.text = @"";
            textLabel.text = item;
            int count = 0;
            for(int i = 0; i < previousPODate.count; i++)
            {
                if([[previousPODate objectAtIndex:i] isEqual:date]){
                    count++;
                }
            }
            if(count == 0){
                isDateRow = YES;
            }
            if(isDateRow){
                UIView *greyBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
                UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, self.bounds.size.width, 20)];
                textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, self.bounds.size.width, 20)];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    greyBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
                    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, self.bounds.size.width, 20)];
                    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 35, self.bounds.size.width, 20)];
                }
                [greyBackground setBackgroundColor:[UIColor lightGrayColor]];
                dateLabel.text =date;
                dateLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:15.0];
                textLabel.text = item;
                [cell addSubview:greyBackground];
                [cell addSubview:dateLabel];
                
            }
            [cell addSubview:textLabel];
        } else if ([[orderDataField lowercaseString] isEqualToString:@"grn"] /*&& ![item isEqualToString:@"Other"]*/
            && !([item caseInsensitiveCompare:@"other"] == NSOrderedSame)){
            //compare with previous and show date only if different
            NSString *previousPO = @"";// [self.comboItems objectAtIndex:indexPath.row-1];
            NSArray* previousPODate = [[NSArray alloc] init];// [self.poAndDateDictionary objectForKey:previousPO];
            if(indexPath.row>0){
                previousPO = [self.comboItems objectAtIndex:indexPath.row-1];
                previousPODate = [self.grnAndDateDictionary objectForKey:previousPO];
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.grnAndDateDictionary objectForKey:item];
            NSNumber *temp = [self.grnAndIndexDictionary objectForKey:item];
            int index = [temp intValue];
            NSString* date = [dateArr objectAtIndex:index];
            //use custom label
            UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.bounds.size.width, 20)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                textLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, self.bounds.size.width, 20)];
            }
            cell.textLabel.text = @"";
            textLabel.text = item;
            int count = 0;
            for(int i = 0; i < previousPODate.count; i++)
            {
                if([[previousPODate objectAtIndex:i] isEqual:date]){
                    count++;
                }
            }
            if(count == 0){
                isDateRow = YES;
            }
            if(isDateRow){
                UIView *greyBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
                UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, self.bounds.size.width, 20)];
                textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, self.bounds.size.width, 20)];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    greyBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
                    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, self.bounds.size.width, 20)];
                    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 35, self.bounds.size.width, 20)];
                }
                [greyBackground setBackgroundColor:[UIColor lightGrayColor]];
                dateLabel.text =date;
                dateLabel.font = [UIFont fontWithName:@"Helvetica-bold" size:15.0];
                textLabel.text = item;
                [cell addSubview:greyBackground];
                [cell addSubview:dateLabel];
                
            }
            [cell addSubview:textLabel];
        }
        
        CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
        if(collobarativeInsp && [CollobarativeInspection isCollaborativeInspectionsEnabled]){
            NSNumber *poStatus = [collobarativeInsp.poStatusMap objectForKey:item];
            NSNumber *supplierStatus = [collobarativeInsp.supplierStatusMap objectForKey:item];
            NSString *orderDataField = self.rating.order_data_field;
            int status = 0;
            if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"]) {
                poStatus = [collobarativeInsp.poStatusMap objectForKey:item];
                status = [poStatus intValue] ;
            } else if ([[orderDataField lowercaseString] isEqualToString:@"vendorname"]) {
                supplierStatus = [collobarativeInsp.supplierStatusMap objectForKey:item];
                status = [supplierStatus intValue] ;
            }
            if(isDateRow)
                self.productStatusButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-50, 30, 30, 30)];
            else
                self.productStatusButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-50, 15, 30, 30)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if(isDateRow)
                    self.productStatusButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-150, 30, 30, 30)];
                else
                    self.productStatusButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-150, 15, 30, 30)];;
            }
            if(status == STATUS_STARTED)
                [self.productStatusButton setBackgroundImage:[UIImage imageNamed:@"halfcircle.png"] forState:normal];
            if(status == STATUS_FINSIHED)
                [self.productStatusButton setBackgroundImage:[UIImage imageNamed:@"circlecheck.png"] forState:normal];
            self.productStatusButton.row = indexPath.row;
            if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"]) {
                [self.productStatusButton addTarget:self action:@selector(showCollaborativeProductMessageForPO:) forControlEvents:UIControlEventTouchUpInside];
            }else if ([[orderDataField lowercaseString] isEqualToString:@"vendorname"]) {
                [self.productStatusButton addTarget:self action:@selector(showCollaborativeProductMessageForSupplier:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if(status != STATUS_NOT_STARTED)
                [cell addSubview:self.productStatusButton];
        }
        
        if([self.flaggedPONumbers objectForKey:item] || [self.flaggedSuppliers objectForKey:item]) {
            cell.textLabel.textColor = [UIColor redColor];
            if(isDateRow)
                self.flaggedProductButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-1, 30, 30, 30)];
            else
                self.flaggedProductButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width-1, 15, 30, 30)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if(isDateRow)
                    self.flaggedProductButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-100, 30, 30, 30)];
                else
                    self.flaggedProductButton = [[RowSectionButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-100, 15, 30, 30)];
            }
            [self.flaggedProductButton setBackgroundImage:[UIImage imageNamed:@"redflag.png"] forState:normal];
            self.flaggedProductButton.row = indexPath.row;
            NSString *orderDataField = self.rating.order_data_field;
            if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"])
                [self.flaggedProductButton addTarget:self action:@selector(showFlaggedPOMessage:) forControlEvents:UIControlEventTouchUpInside];
            else if ([[orderDataField lowercaseString] isEqualToString:@"vendorname"])
                [self.flaggedProductButton addTarget:self action:@selector(showFlaggedSupplierMessage:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:self.flaggedProductButton];
        }
        if(total != 0.0)
        {
        if(([[orderDataField lowercaseString] isEqualToString:@"ponumber"]) || ([[orderDataField lowercaseString] isEqualToString:@"vendorname"]) || ([[orderDataField lowercaseString] isEqualToString:@"customername"]) || ([[orderDataField lowercaseString] isEqualToString:@"grn"])){
        if(!([item caseInsensitiveCompare:@"other"] == NSOrderedSame)){
        if(isDateRow)
        {
        UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.bounds.size.width-60, 25, 45, 45)];
        scoreLabel.text = [NSString stringWithFormat:@"%.02f",avg];
        if((avg >= 0) && (avg <= 40)){
            scoreLabel.layer.borderColor = [UIColor redColor].CGColor;
        }else if((avg >= 41) && (avg <= 70)){
            scoreLabel.layer.borderColor = [UIColor orangeColor].CGColor;
        }else{
            scoreLabel.layer.borderColor = [UIColor greenColor].CGColor;
        }
        
        scoreLabel.layer.borderWidth = 2.0;
        scoreLabel.layer.cornerRadius = scoreLabel.frame.size.width/2;
        scoreLabel.textAlignment = NSTextAlignmentCenter;
        scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
        [cell addSubview:scoreLabel];
        }else{
            UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.bounds.size.width-60, 5, 45, 45)];
            scoreLabel.text = [NSString stringWithFormat:@"%.02f",avg];
            if((avg >= 0) && (avg <= 40)){
                scoreLabel.layer.borderColor = [UIColor redColor].CGColor;
            }else if((avg >= 41) && (avg <= 70)){
                scoreLabel.layer.borderColor = [UIColor orangeColor].CGColor;
            }else{
                scoreLabel.layer.borderColor = [UIColor greenColor].CGColor;
            }
            
            scoreLabel.layer.borderWidth = 2.0;
            scoreLabel.layer.cornerRadius = scoreLabel.frame.size.width/2;
            scoreLabel.textAlignment = NSTextAlignmentCenter;
            scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
            [cell addSubview:scoreLabel];
        }
        }
        }
        }
    } else if (popoverListView == self.poplistviewDates) {
        cell.textLabel.text = [self.comboItemsForDates objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void) showFlaggedSupplierMessage:(RowSectionButton*)sender {
    NSString *item =[self.comboItems objectAtIndex:sender.row];
    NSString* message =[self.flaggedPONumbers objectForKey:item];
    if(!message)
        message = [self.flaggedSuppliers objectForKey:item];
    message = [NSString stringWithFormat:@"Products for \n%@ \nhave been flagged for special attention",item];
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog show];
    
}

- (void) showFlaggedPOMessage:(RowSectionButton*)sender {
    NSString *item =[self.comboItems objectAtIndex:sender.row];
    NSString* message =[self.flaggedPONumbers objectForKey:item];
    if(!message)
        message = [self.flaggedSuppliers objectForKey:item];
    message = [NSString stringWithFormat:@"Products for \nPO#%@ \nhave been flagged for special attention",item];
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog show];
    
}

- (void) showCollaborativeProductMessageForPO:(RowSectionButton*)sender {
    NSString *item =[self.comboItems objectAtIndex:sender.row];
    NSString* message =@"";//[self.flaggedPONumbers objectForKey:item];
    
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(collobarativeInsp && [CollobarativeInspection isCollaborativeInspectionsEnabled]){
        NSNumber *poStatus = [collobarativeInsp.poStatusMap objectForKey:item];
        NSNumber *supplierStatus = [collobarativeInsp.supplierStatusMap objectForKey:item];
        int status = 0;
        status = [poStatus intValue] ;
        
        NSString* users = @"";
        NSMutableSet* listOfUsersSet = [[Inspection sharedInspection].collobarativeInspection getListOfUsersForPO:item];
        NSArray *listOfUsersArray = [listOfUsersSet allObjects];
        users = [listOfUsersArray componentsJoinedByString:@"\n"];
        
        
        if(status == STATUS_STARTED)
            message = [NSString stringWithFormat:@"Inspections for \nPO #%@\n have been started by %@",item,users];
        if(status == STATUS_FINSIHED)
            message = [NSString stringWithFormat:@"Inspections for \nPO #%@\n have been finished by %@",item,users];
    }
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog show];
    
}

- (void) showCollaborativeProductMessageForSupplier:(RowSectionButton*)sender {
    NSString *item =[self.comboItems objectAtIndex:sender.row];
    NSString* message =@""; //[self.flaggedPONumbers objectForKey:item];
    
    CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
    if(collobarativeInsp && [CollobarativeInspection isCollaborativeInspectionsEnabled]){
        NSNumber *supplierStatus = [collobarativeInsp.supplierStatusMap objectForKey:item];
        int status = 0;
        status = [supplierStatus intValue] ;
        
        NSString* users = @"";
        NSMutableSet* listOfUsersSet = [[Inspection sharedInspection].collobarativeInspection getListOfUsersForSupplier:item];
        NSArray *listOfUsersArray = [listOfUsersSet allObjects];
        users = [listOfUsersArray componentsJoinedByString:@"\n"];
        
        if(status == STATUS_STARTED)
            message = [NSString stringWithFormat:@"Inspections for \n%@\n have been started by %@",item,users];
        if(status == STATUS_FINSIHED)
            message = [NSString stringWithFormat:@"Inspections for \n%@\n have been finished by %@",item,users];
    }
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [dialog show];
    
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    if (popoverListView == self.poplistview) {
        return [self.comboItems count];
    } else {
        return [self.comboItemsForDates count];
    }
}

- (void) textFieldText: (NSString *) text withTableView:(UITableView *) tableView {
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if (self.poplistview) {
        for (int i=0; i < [self.comboItems count]; i++) {
            NSString *comboText = [NSString stringWithFormat:@"%@", [self.comboItems objectAtIndex:i]];
            //if ([[comboText lowercaseString] hasPrefix:[text lowercaseString]]) {
            if(!([[comboText lowercaseString] rangeOfString:[text lowercaseString]].location == NSNotFound)){
                newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                NSLog(@"index pah i %d", i);
                break;
            }
        }
    } else {
        for (int i=0; i < [self.comboItems count]; i++) {
            NSString *comboText = [NSString stringWithFormat:@"%@", [self.comboItemsForDates objectAtIndex:i]];
            //if ([[comboText lowercaseString] hasPrefix:text]) {
            if(!([[comboText lowercaseString] rangeOfString:[text lowercaseString]].location == NSNotFound)){
                newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                NSLog(@"index pah i %d", i);
                break;
            }
        }
    }
    [tableView scrollToRowAtIndexPath:newIndexPath
                     atScrollPosition:UITableViewScrollPositionTop
                             animated:NO];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    ProductRatingViewController *productRatingViewController = (ProductRatingViewController *)self.myTableViewController;
    if ([productRatingViewController.parentView isEqualToString:defineContainerViewController] && [self.rating.order_data_field isEqualToString:@"VendorName"]) {
        [self saveSelectedVendorNameToUserDefaults:indexPath];
        NSArray *ratings = productRatingViewController.ratingsGlobal;
        BOOL temp = NO;
        for(Rating *rating in ratings){
            if([[rating.order_data_field lowercaseString] isEqualToString:@"grn"]){
                temp = YES;
                break;
            }
        }
        NSString *poNumber;
        if(!temp)
           poNumber = [self autoSelectPOIfPresent];
        else{
            poNumber = [self autoSelectGRNIfPresent];
        }
        NSString *vendorName = [self.comboItems objectAtIndex:indexPath.row];
        
        //filter by loadId
        if([self isLoadIdSet]){
            NSString* loadId = [self getSelectedLoadId];
            NSArray* poArray = [self getPOBySupplier:vendorName withLoadId:loadId];
            if([poArray count]>0)
                poNumber = [poArray objectAtIndex:0];
        }
        
        //DI-1908 - Selecting a different supplier should select the correct PO
        if (![poNumber isEqualToString:@""]  /*![vendorName isEqualToString:@"Other"]*/
            || !([vendorName caseInsensitiveCompare:@"other"] == NSOrderedSame)) {
            
            //load-id
            
            
            [[self delegate] refreshTheView:poNumber];
            
            if(!temp){
                [self updateLoadIdWithSupplier:vendorName withPO:poNumber];
            [self callDatePickerForPOsAlone:[NSIndexPath indexPathForRow:0 inSection:1]];
            }
            else{
                [self updateLoadIdWithSupplier:vendorName withGRN:poNumber];
                [self callDatePickerForGRNAlone:[NSIndexPath indexPathForRow:0 inSection:1]];
            }
        }
    }
    if ([productRatingViewController.parentView isEqualToString:defineContainerViewController] && [[self.rating.order_data_field lowercaseString] isEqualToString:@"ponumber"]) {
        NSLog(@"poselected");
        if(![User sharedUser].userSelectedVendorName || [[User sharedUser].userSelectedVendorName isEqualToString:@""])
            self.delegate.poSelectedFirst = YES;
        [self saveSelectedPONumber:indexPath];
        NSString *poNumber = [self.comboItems objectAtIndex:indexPath.row];
        if(![poNumber isEqualToString:@"None"] /*&& ![poNumber isEqualToString:@"Other"]*/
           && !([poNumber caseInsensitiveCompare:@"other"] == NSOrderedSame)){
            NSString *vendorName = [self autoSelectVendorIfPresent];
            if (![vendorName isEqualToString:@""]) {
                
                //customer name
                [self updateCustomerNameForPO:poNumber];
                
                if([[self delegate] isContainerRatingPresentWithOrderDataField:@"customername"]){
                    NSString* value = [self getSupplierForReceivingInspection];
                    if(value && ![value isEqualToString:@"None"])
                        vendorName = value;
                }
                
                //load-id
                [self updateLoadIdWithSupplier:vendorName withPO:poNumber];
                
                [User sharedUser].userSelectedVendorName = vendorName;
                [[self delegate] refreshTheViewForVendorName:vendorName];
            }
        }
    }
    if ([productRatingViewController.parentView isEqualToString:defineContainerViewController] && [[self.rating.order_data_field lowercaseString] isEqualToString:@"grn"]) {
        NSLog(@"grn selected");
        if(![User sharedUser].userSelectedVendorName || [[User sharedUser].userSelectedVendorName isEqualToString:@""])
            self.delegate.grnSelectedFirst = YES;
        [self saveSelectedGRN:indexPath];
        NSString *grn = [self.comboItems objectAtIndex:indexPath.row];
        if(![grn isEqualToString:@"None"] /*&& ![poNumber isEqualToString:@"Other"]*/
           && !([grn caseInsensitiveCompare:@"other"] == NSOrderedSame)){
            NSString *vendorName = [self autoSelectVendorIfPresent];
            if (![vendorName isEqualToString:@""]) {
                
                //customer name
                [self updateCustomerNameForGRN:grn];
                
                if([[self delegate] isContainerRatingPresentWithOrderDataField:@"customername"]){
                    NSString* value = [self getSupplierForReceivingInspection];
                    if(value && ![value isEqualToString:@"None"])
                        vendorName = value;
                }
                [self updateLoadIdWithSupplier:vendorName withGRN:grn];
                [User sharedUser].userSelectedVendorName = vendorName;
                [[self delegate] refreshTheViewForVendorName:vendorName];
            }
        }
    }
    if ([productRatingViewController.parentView isEqualToString:defineContainerViewController] &&
        [[self.rating.order_data_field lowercaseString] isEqualToString:@"loadid"]) {
        NSLog(@"load-id selected");
        
        NSString *loadId = [self.comboItems objectAtIndex:indexPath.row];
        BOOL isLoadIdValid =(![loadId isEqualToString:@"None"])
        && !([loadId caseInsensitiveCompare:@"other"] == NSOrderedSame);
        
        
        //if 1 unique supplier for load-id, do not filter
        int uniqueSupplierForLoadId = [self numberOfUniqueSuppliersForLoadId:loadId];
        if(isLoadIdValid && uniqueSupplierForLoadId == 1){
            [self updateSupplierAndPOForLoadId:loadId]; //update supplier/PO for LoadId
        }
        else{
            [self.delegate resetView]; //Other selected - need to reset PO/supplier
            [[self delegate] resetOrderDataComboRatingWithKey:@"ponumber"];
        }
        
        [self saveSelectedLoadId:indexPath];
        
        if(isLoadIdValid){
            [[self delegate] refreshTheView];
        }
        [self callDatePickerForPOsAlone:[NSIndexPath indexPathForRow:0 inSection:1]];
        //[self callDatePickerForPOsAlone:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    if ([productRatingViewController.parentView isEqualToString:defineContainerViewController] && [self.rating.order_data_field isEqualToString:@"CustomerName"]) {
        //save customer name
        [self saveSelectedCustomerNameToUserDefaults:indexPath];
        NSString *poNumber = [self autoSelectPOIfPresentForCustomer];
        NSString *customerName = [self.comboItems objectAtIndex:indexPath.row];
        
        //DI-1908 - Selecting a different supplier should select the correct PO
        if (![poNumber isEqualToString:@""]  /*![vendorName isEqualToString:@"Other"]*/
            || !([customerName caseInsensitiveCompare:@"other"] == NSOrderedSame)) {
            
            //[[self delegate] refreshTheView:poNumber];
            [[self delegate] refreshTheView:poNumber];
            [self callDatePickerForPOsAlone:[NSIndexPath indexPathForRow:0 inSection:1]];
        }
    }
    
    if (popoverListView == self.poplistviewDates) {
        [self dateSelectedFromPicker:indexPath];
    } else if (popoverListView == self.poplistview) {
        [self callDatePicker:indexPath];
    }
    if (popoverListView == self.poplistview) {
        [self selectedOtherTextField:indexPath];
    }
}

- (int)numberOfUniqueSuppliersForLoadId:(NSString*)loadId {
    int numberOfSuppliers = 0;
    NSArray *allOrderDataObjects =  [self getOrderData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loadId==%@",loadId];
    NSArray *results = [allOrderDataObjects filteredArrayUsingPredicate:predicate];
    NSArray *filteredEvents =  [results valueForKeyPath:@"@distinctUnionOfObjects.VendorName"];
    numberOfSuppliers = [filteredEvents count];
    return numberOfSuppliers;
}

-(NSString*) getSupplierForReceivingInspection {
    NSString* po = [User sharedUser].temporaryPONumberFromUserClass;
    NSString* customerName = [User sharedUser].userSelectedCustomerName;
    NSString* autoSelectVendorName = nil;
    
    
    
    if(po && ![po isEqualToString:@"None"] && customerName && ![customerName isEqualToString:@"None"]){
        //if customer and PO are selected
        //vendor name from order data
        NSString* vendorName = [self getVendorNameForPO:po withCustomerName:customerName];
        autoSelectVendorName =  vendorName;
    }else{
        //if only Customer is selected
        //vendor name none
        //if only PO is selected
        //vendor name none
        //if Customer / PO are not selected
        //vendor name none
        autoSelectVendorName = @"None";
    }
    return autoSelectVendorName;
}

-(NSString*)getVendorNameForPO:(NSString*)po withCustomerName:(NSString*)customerName {
    NSArray *allOrderData = [self getOrderData];
    for (OrderData *orderData in allOrderData) {
        if ([orderData.PONumber isEqualToString:po] &&
            [orderData.CustomerName isEqualToString:customerName]) {
            return orderData.VendorName;
        }
    }
    return nil;
}

/*
 - (int)numberOfUniquePOForLoadId:(NSString*)loadId withSupplier:(NSString*)supplier {
 int numberOfSuppliers = 0;
 NSArray *allOrderDataObjects =  [self getOrderData];
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loadId==%@ AND VendorName=%@",loadId,supplier];
 NSArray *results = [allOrderDataObjects filteredArrayUsingPredicate:predicate];
 NSArray *filteredEvents =  [results valueForKeyPath:@"@distinctUnionOfObjects.PONumber"];
 numberOfSuppliers = [filteredEvents count];
 return numberOfSuppliers;
 }
 
 -(int)numberOfSuppliersForLoadId:(NSString*)loadId withPO:(NSString*)poNumber {
 
 return 0;
 }
 */
-(void)updateSupplierAndPOForLoadId:(NSString*)loadId {
    //get ponumber & supplier and set
    NSString* supplier = @"";
    NSArray* filteredSupplier = [self filterVendorByLoadId:loadId];
    
    if(filteredSupplier && [filteredSupplier count]>0)
        supplier = [filteredSupplier objectAtIndex:0];
    
    //save PO/Supplier and refresh the view
    [User sharedUser].userSelectedVendorName = supplier;
    
    NSArray* poArray = [self getPOBySupplier:supplier withLoadId:loadId];
    self.poNumbersArray = poArray;
    NSArray *filteredEvents =  [poArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
    int uniquePOCount = [filteredEvents count];
    //auto select only when 1 PO is filtered
    if(uniquePOCount==1){
        NSString* po = [poArray objectAtIndex:0];
        [self callDatePickerForPOsAlone:[NSIndexPath indexPathForRow:0 inSection:1]];
        [User sharedUser].temporaryPONumberFromUserClass = po;
        [[Inspection sharedInspection] savePONumberToInspection:po];
        [[self delegate] refreshTheView:po];
    }else{
        [User sharedUser].temporaryPONumberFromUserClass = nil;
        [[Inspection sharedInspection] savePONumberToInspection:nil];
        [[self delegate] refreshTheView:@""];
    }
}

-(void)populatePONumbersForLoadId:(NSString*)loadId {
    NSString* supplier = @"";
    NSArray* filteredSupplier = [self filterVendorByLoadId:loadId];
    
    if(filteredSupplier && [filteredSupplier count]>0)
        supplier = [filteredSupplier objectAtIndex:0];
    
    NSArray* poArray = [self getPOBySupplier:supplier withLoadId:loadId];
    self.poNumbersArray = poArray;
}

- (void) callDatePicker: (NSIndexPath *) indexPath {
    NSString *comboItem = [self.comboItems objectAtIndex:indexPath.row];
    if([comboItem isEqualToString:@"None"]){
        [[Inspection sharedInspection] savePONumberToInspection:[self.comboItems objectAtIndex:indexPath.row]];
    }
    if ([self.poNumbersArray containsObject:comboItem]) {
        self.comboItemsForDates = [[self findUniqueDatesForPONumber:comboItem] mutableCopy];
        if ([self.comboItemsForDates count] == 1) {
            [Inspection sharedInspection].dateTimeForOrderData = [self.comboItemsForDates objectAtIndex:0];
            [NSUserDefaultsManager saveObjectToUserDefaults:[self.comboItemsForDates objectAtIndex:0] withKey:OrderDataDateTimeSet];
        } else if ([self.comboItemsForDates count] > 1) {
            int count = 0;
            for(int i = 0; i < indexPath.row; i++){
                NSString *temp = [self.comboItems objectAtIndex:i];
                if([comboItem isEqualToString:temp]){
                    count++;
                }
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.poAndDateDictionary objectForKey:comboItem];
            NSString *date = [dateArr objectAtIndex:count];
            [Inspection sharedInspection].dateTimeForOrderData = date;
            [NSUserDefaultsManager saveObjectToUserDefaults:date withKey:OrderDataDateTimeSet];
            //[self selectOptionsDates:self.comboItemsForDates withTitle:@"  Select Date"];
        }
        [[Inspection sharedInspection] savePONumberToInspection:[self.comboItems objectAtIndex:indexPath.row]];
    } else if ([self.grnArray containsObject:comboItem]) {
        self.comboItemsForDates = [[self findUniqueDatesForGRN:comboItem] mutableCopy];
        if ([self.comboItemsForDates count] == 1) {
            [Inspection sharedInspection].dateTimeForOrderData = [self.comboItemsForDates objectAtIndex:0];
            [NSUserDefaultsManager saveObjectToUserDefaults:[self.comboItemsForDates objectAtIndex:0] withKey:OrderDataDateTimeSet];
        } else if ([self.comboItemsForDates count] > 1) {
            int count = 0;
            for(int i = 0; i < indexPath.row; i++){
                NSString *temp = [self.comboItems objectAtIndex:i];
                if([comboItem isEqualToString:temp]){
                    count++;
                }
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.grnAndDateDictionary objectForKey:comboItem];
            NSString *date = [dateArr objectAtIndex:count];
            [Inspection sharedInspection].dateTimeForOrderData = date;
            [NSUserDefaultsManager saveObjectToUserDefaults:date withKey:OrderDataDateTimeSet];
            //[self selectOptionsDates:self.comboItemsForDates withTitle:@"  Select Date"];
        }
        [[Inspection sharedInspection] saveGRNToInspection:[self.comboItems objectAtIndex:indexPath.row]];
    }else if ([self.vendorNamesArray containsObject:comboItem]) {
        
    }
}

- (void) callDatePickerForPOsAlone: (NSIndexPath *) indexPath {
    NSString *comboItem = [self.poNumbersArray objectAtIndex:indexPath.row];
    if ([self.poNumbersArray containsObject:comboItem]) {
        self.comboItemsForDates = [[self findUniqueDatesForPONumber:comboItem] mutableCopy];
        if ([self.comboItemsForDates count] == 1) {
            [Inspection sharedInspection].dateTimeForOrderData = [self.comboItemsForDates objectAtIndex:0];
            [NSUserDefaultsManager saveObjectToUserDefaults:[self.comboItemsForDates objectAtIndex:0] withKey:OrderDataDateTimeSet];
        } else if ([self.comboItemsForDates count] > 1) {
            int count = 0;
            for(int i = 0; i < indexPath.row; i++){
                NSString *temp = [self.comboItems objectAtIndex:i];
                if([comboItem isEqualToString:temp]){
                    count++;
                }
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.poAndDateDictionary objectForKey:comboItem];
            NSString *date = [dateArr objectAtIndex:count];
            [Inspection sharedInspection].dateTimeForOrderData = date;
            [NSUserDefaultsManager saveObjectToUserDefaults:date withKey:OrderDataDateTimeSet];
            //[self selectOptionsDates:self.comboItemsForDates withTitle:@"  Select Date"];
        }
        [[Inspection sharedInspection] savePONumberToInspection:[self.poNumbersArray objectAtIndex:indexPath.row]];
    } else if ([self.vendorNamesArray containsObject:comboItem]) {
        
    }
}
- (void) callDatePickerForGRNAlone: (NSIndexPath *) indexPath {
    NSString *comboItem = [self.grnArray objectAtIndex:indexPath.row];
    if ([self.grnArray containsObject:comboItem]) {
        self.comboItemsForDates = [[self findUniqueDatesForGRN:comboItem] mutableCopy];
        if ([self.comboItemsForDates count] == 1) {
            [Inspection sharedInspection].dateTimeForOrderData = [self.comboItemsForDates objectAtIndex:0];
            [NSUserDefaultsManager saveObjectToUserDefaults:[self.comboItemsForDates objectAtIndex:0] withKey:OrderDataDateTimeSet];
        } else if ([self.comboItemsForDates count] > 1) {
            int count = 0;
            for(int i = 0; i < indexPath.row; i++){
                NSString *temp = [self.comboItems objectAtIndex:i];
                if([comboItem isEqualToString:temp]){
                    count++;
                }
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.grnAndDateDictionary objectForKey:comboItem];
            NSString *date = [dateArr objectAtIndex:count];
            [Inspection sharedInspection].dateTimeForOrderData = date;
            [NSUserDefaultsManager saveObjectToUserDefaults:date withKey:OrderDataDateTimeSet];
            //[self selectOptionsDates:self.comboItemsForDates withTitle:@"  Select Date"];
        }
        [[Inspection sharedInspection] saveGRNToInspection:[self.grnArray objectAtIndex:indexPath.row]];
    } else if ([self.vendorNamesArray containsObject:comboItem]) {
        
    }
}
- (void) saveSelectedVendorNameToUserDefaults: (NSIndexPath *) indexPath {
    NSString *dcName = [self.comboItems objectAtIndex:indexPath.row];
    [User sharedUser].userSelectedVendorName = dcName;
    self.selectLabel.text = dcName;
    [NSUserDefaultsManager saveObjectToUserDefaults:dcName withKey:VendorNameSelected];
}

- (void) saveSelectedPONumber: (NSIndexPath *) indexPath {
    NSString *poNumber = [self.comboItems objectAtIndex:indexPath.row];
    [User sharedUser].temporaryPONumberFromUserClass = poNumber;
}
- (void) saveSelectedGRN: (NSIndexPath *) indexPath {
    NSString *grn = [self.comboItems objectAtIndex:indexPath.row];
    [User sharedUser].temporaryGRNFromUserClass = grn;
}
-(void)saveSelectedLoadId : (NSIndexPath *) indexPath {
    NSString *loadId = [self.comboItems objectAtIndex:indexPath.row];
    self.selectLabel.text = loadId;
    self.rating.ratingAnswerFromUI = loadId;
    [self setLoadId:loadId];
}

- (void) saveSelectedCustomerNameToUserDefaults: (NSIndexPath *) indexPath {
    NSString *customerName = [self.comboItems objectAtIndex:indexPath.row];
    [User sharedUser].userSelectedCustomerName = customerName;
    self.selectLabel.text = customerName;
    self.rating.ratingAnswerFromUI = customerName;
    [NSUserDefaultsManager saveObjectToUserDefaults:customerName withKey:CustomerNameSelected];
}

- (void) dateSelectedFromPicker: (NSIndexPath *) indexPath {
    //NSLog(@"set ponumber date for the inspection");
    NSString *selectedDate = [self.comboItemsForDates objectAtIndex:indexPath.row];
    [Inspection sharedInspection].dateTimeForOrderData = selectedDate;
    [NSUserDefaultsManager saveObjectToUserDefaults:selectedDate withKey:OrderDataDateTimeSet];
    [[[UIAlertView alloc] initWithTitle:@"Date Selected" message: @"" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    [self.comboItemsForDates removeAllObjects];
}

- (void) selectedOtherTextField: (NSIndexPath *) indexPath {
    if ([self.comboItems count] > 0) {
        self.selectLabel.text = [self.comboItems objectAtIndex:indexPath.row];
        NSString *otherString = [[self.comboItems objectAtIndex:indexPath.row] lowercaseString];
        if ([self isOther:otherString]) {
            self.otherTextField.hidden = NO;
            if ([[Inspection sharedInspection] checkForOrderData]) {
                [[Inspection sharedInspection] deletePONumberFromUserDefaults];
                [Inspection sharedInspection].poNumberGlobal = @"";
            }
            //self.selectOptionButton.frame = CGRectMake(20, 6, 280, 38);
        } else {
            self.otherTextField.hidden = YES;
        }
    }
}

- (void)popoverListViewCancel:(UIPopoverListView *)popoverListView {
    NSLog(@"ponumber date for the inspection");
    
    [[self delegate] resetOrderDataComboRatingWithKey:@"loadid"];
    [[self delegate] resetOrderDataComboRatingWithKey:@"customername"];
    [[self delegate]resetView];
}

-(void)reset{
    self.poNumbersArray = [[NSMutableArray alloc]init];
    self.grnArray = [[NSMutableArray alloc]init];
    self.vendorNamesFilteredArray = [[NSMutableArray alloc]init];
    self.vendorNamesArray = [[NSMutableArray alloc]init];
    self.comboItems = [[NSMutableArray alloc]init];
    self.comboItemsGlobal = [[NSMutableArray alloc]init];
    self.comboItemsForDates = [[NSMutableArray alloc]init];
    
    [User sharedUser].userSelectedVendorName = nil;
    [NSUserDefaultsManager saveObjectToUserDefaults:nil withKey:VendorNameSelected];
    [User sharedUser].userSelectedCustomerName = nil;
    [NSUserDefaultsManager saveObjectToUserDefaults:nil withKey:CustomerNameSelected];
    [User sharedUser].temporaryPONumberFromUserClass = nil;
    [User sharedUser].temporaryGRNFromUserClass = nil;
    self.rating.ratingAnswerFromUI = @"";
    self.delegate.poSelectedFirst = NO;
    self.delegate.grnSelectedFirst = NO;
    [[Inspection sharedInspection] savePONumberToInspection:nil];
    [self setLoadId:@""];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if PO Row with Date - increase height - DI-2073
    if (popoverListView == self.poplistview) {
        NSString *item =[self.comboItems objectAtIndex:indexPath.row];
        NSString *orderDataField = self.rating.order_data_field;
        if ([[orderDataField lowercaseString] isEqualToString:@"ponumber"] /*&& ![item isEqualToString:@"Other"]*/
            && !([item caseInsensitiveCompare:@"other"] == NSOrderedSame) ){
            //compare with previous and show date only if different
            NSString *previousPO = @"";// [self.comboItems objectAtIndex:indexPath.row-1];
            NSArray* previousPODate = [[NSArray alloc] init];// [self.poAndDateDictionary objectForKey:previousPO];
            BOOL isDateRow = NO;
            if(indexPath.row>0){
                previousPO = [self.comboItems objectAtIndex:indexPath.row-1];
                previousPODate = [self.poAndDateDictionary objectForKey:previousPO];
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.poAndDateDictionary objectForKey:item];
            
            NSNumber *temp = [self.poAndIndexDictionary objectForKey:item];
            int index = [temp intValue];
            NSString* date = [dateArr objectAtIndex:index];
            index++;
            if(index == dateArr.count){
                index = 0;
            }
            [self.poAndIndexDictionary setObject:[NSNumber numberWithInteger:index] forKey:item];
            int count = 0;
            for(int i = 0; i < previousPODate.count; i++)
            {
                if([[previousPODate objectAtIndex:i] isEqual:date]){
                    count++;
                }
            }
            if(count == 0){
                isDateRow = YES;
            }
            if(isDateRow){
                //date row
                return 80.0f;
            }
        } else if ([[orderDataField lowercaseString] isEqualToString:@"grn"] /*&& ![item isEqualToString:@"Other"]*/
            && !([item caseInsensitiveCompare:@"other"] == NSOrderedSame) ){
            //compare with previous and show date only if different
            NSString *previousGRN = @"";// [self.comboItems objectAtIndex:indexPath.row-1];
            NSArray* previousGRNDate = [[NSArray alloc] init];// [self.poAndDateDictionary objectForKey:previousPO];
            BOOL isDateRow = NO;
            if(indexPath.row>0){
                previousGRN = [self.comboItems objectAtIndex:indexPath.row-1];
                previousGRNDate = [self.grnAndDateDictionary objectForKey:previousGRN];
            }
            NSArray *dateArr = [[NSArray alloc] init];
            dateArr = [self.grnAndDateDictionary objectForKey:item];
            
            NSNumber *temp = [self.grnAndIndexDictionary objectForKey:item];
            int index = [temp intValue];
            NSString* date = [dateArr objectAtIndex:index];
            index++;
            if(index == dateArr.count){
                index = 0;
            }
            [self.poAndIndexDictionary setObject:[NSNumber numberWithInteger:index] forKey:item];
            int count = 0;
            for(int i = 0; i < previousGRNDate.count; i++)
            {
                if([[previousGRNDate objectAtIndex:i] isEqual:date]){
                    count++;
                }
            }
            if(count == 0){
                isDateRow = YES;
            }
            if(isDateRow){
                //date row
                return 80.0f;
            }
        }
    }
    
    return 60.0f;
}

- (NSArray *) findUniqueDatesForPONumber: (NSString *) PONumberLocal {
    NSArray *dates = [[NSArray alloc] init];
    if (PONumberLocal && ![PONumberLocal isEqualToString:@""]) {
        NSMutableSet *mutableSetLocal = [NSMutableSet set];
        for (OrderData *orderData in self.orderDataObjectsForPoNumbers) {
            if ([orderData.PONumber isEqualToString:PONumberLocal]) {
                //NSString *dateReceived = orderData.ReceivedDateTime;
                NSString *dateExpected = orderData.ExpectedDeliveryDateTime;
                if (![dateExpected isEqualToString:@""] && dateExpected) {
                    [mutableSetLocal addObject:orderData.ExpectedDeliveryDateTime];
                } else {
                    [mutableSetLocal addObject:orderData.ReceivedDateTime];
                }
            }
        }
        dates = [mutableSetLocal allObjects];
        //NSLog(@"dvfvljnfdsm %@", mutableSetLocal);
    }
    return dates;
}

- (NSArray *) findUniqueDatesForGRN: (NSString *) grnLocal {
    NSArray *dates = [[NSArray alloc] init];
    if (grnLocal && ![grnLocal isEqualToString:@""]) {
        NSMutableSet *mutableSetLocal = [NSMutableSet set];
        for (OrderData *orderData in self.orderDataObjectsForGRN) {
            if ([orderData.grn isEqualToString:grnLocal]) {
                //NSString *dateReceived = orderData.ReceivedDateTime;
                NSString *dateExpected = orderData.ExpectedDeliveryDateTime;
                if (![dateExpected isEqualToString:@""] && dateExpected) {
                    [mutableSetLocal addObject:orderData.ExpectedDeliveryDateTime];
                } else {
                    [mutableSetLocal addObject:orderData.ReceivedDateTime];
                }
            }
        }
        dates = [mutableSetLocal allObjects];
        //NSLog(@"dvfvljnfdsm %@", mutableSetLocal);
    }
    return dates;
}
- (NSString*)theAnswerAsStringForNumericRating
{
    return @"";
}

- (NSString*)theAnswerAsStringForNumericAndPriceRating
{
    return @"";
}


@end
