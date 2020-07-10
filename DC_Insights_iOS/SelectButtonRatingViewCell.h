//
//  SelectButtonRatingViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/17/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewCell.h"
#import "UIPopoverListView.h"
#import "SyncOverlayView.h"
//#import "SWBarcodePickerManager.h"
#import "RowSectionButton.h"

@protocol SelectButtonRatingCellDelegate <NSObject>
- (void) refreshTheView;
- (void) refreshTheView: (NSString *) string;
- (void) refreshTheViewForVendorName: (NSString *) string;
-(void)resetView;
-(void)resetOrderDataComboRatingWithKey:(NSString*)orderDataKey;
- (void) setOrderDataComboRatingValue:(NSString *) string withOrderDataKey:(NSString*)orderDatakey;
-(BOOL)isContainerRatingPresentWithOrderDataField:(NSString*)orderDataKey;
//-(NSArray*)getOrderDataByContainer;

@property (nonatomic, assign) BOOL poSelectedFirst;
@property (nonatomic, assign) BOOL grnSelectedFirst;
@property (nonatomic, assign) BOOL supplierSelectedFirst;
@end

#define kSelectButtonRatingViewCellReuseID @"SelectButtonRatingViewCell"
#define kSelectButtonRatingViewCellNIBFile @"SelectButtonRatingViewCell"

@interface SelectButtonRatingViewCell : BaseTableViewCell <UIPopoverListViewDelegate, UIPopoverListViewDataSource, ScannerProtocol>

@property (retain, nonatomic) IBOutlet UIButton *selectOptionButton;
@property (retain, nonatomic) IBOutlet UILabel *selectLabel;
@property (retain, nonatomic) IBOutlet UITextField *otherTextField;
@property (retain, nonatomic) IBOutlet UIToolbar *utilityButtonView;
@property (retain, nonatomic) NSArray *poNumbersArray;
@property (retain, nonatomic) NSArray *grnArray;
@property (retain, nonatomic) NSArray *loadIdArray;
@property (retain, nonatomic) NSArray *vendorNamesFilteredArray;
@property (retain, nonatomic) NSArray *vendorNamesArray;
@property (retain, nonatomic) NSMutableArray *comboItems;
@property (retain, nonatomic) NSMutableArray *comboItemsGlobal;
@property (retain, nonatomic) NSMutableArray *comboItemsForDates;
@property (retain, nonatomic) NSMutableDictionary *flaggedPONumbers;
@property (retain, nonatomic) NSMutableDictionary *flaggedGRNs;
@property (retain, nonatomic) NSMutableDictionary *flaggedSuppliers;
@property (retain, nonatomic) NSMutableDictionary *poAndDateDictionary;
@property (retain, nonatomic) NSMutableDictionary *grnAndDateDictionary;
@property (retain, nonatomic) NSMutableDictionary *poAndScoreDictionary;
@property (retain, nonatomic) NSMutableDictionary *grnAndScoreDictionary;
@property (retain, nonatomic) NSMutableDictionary *vendorAndScoreDictionary;
@property (retain, nonatomic) NSMutableDictionary *customerAndScoreDictionary;
@property (retain, nonatomic) NSMutableDictionary *poAndIndexDictionary;
@property (retain, nonatomic) NSMutableDictionary *grnAndIndexDictionary;
@property (retain, nonatomic) NSArray *orderDataObjectsForPoNumbers;
@property (retain, nonatomic) NSArray *orderDataObjectsForGRN;
@property (retain, nonatomic) NSArray *orderDataObjectsForLoadIds;
@property (retain, nonatomic) UIPopoverListView *poplistview;
@property (retain, nonatomic) UIPopoverListView *poplistviewDates;
@property (nonatomic, weak) id <SelectButtonRatingCellDelegate> delegate;
@property (retain, nonatomic) SyncOverlayView *syncOverlayView;
@property (nonatomic, strong) RowSectionButton *flaggedProductButton;
@property (nonatomic, strong) RowSectionButton *productStatusButton;
@property (nonatomic, assign) BOOL noOptionSelected;


-(void)reset;

- (IBAction)bringTheOptions:(id)sender;

@end
