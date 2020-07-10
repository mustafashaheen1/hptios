//
//  ProductSelectAutoCompleteViewController.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/19/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentNavigationViewController.h"
#import "ProductSelectSectionHeader.h"
#import "SKSTableView.h"
#import "SyncOverlayView.h"
#import "UIPopoverListView.h"
#import "Product.h"
#import "RowSectionButton.h"
#import "ContainerViewController.h"

//TODO: make this file replacement of ProductSelectAutoCompleteViewController for Retail-Insights mode
@interface RetailProductListViewController : ParentNavigationViewController <UITableViewDataSource, UITableViewDelegate, SectionHeaderViewDelegate, SKSTableViewDelegate, UIPopoverListViewDataSource, UIPopoverListViewDelegate>

@property (nonatomic, strong) NSMutableArray *productGroups;
@property (nonatomic, strong) NSArray *productGroupsDidSelectGlobalArray;
@property (nonatomic, strong) NSArray *productGroupsArrayForAutoComplete;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSMutableArray *productStatuses;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, strong) NSMutableArray *sectionInfoArray;
@property (nonatomic, strong) NSMutableArray *sectionHeaderTitleArray;
@property (nonatomic, strong) NSMutableDictionary *dictFruits;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) IBOutlet UIButton *showAllProductsButton;
@property (nonatomic, strong) NSArray *productAudits;
@property (nonatomic, strong) NSDictionary *countOfCasesDict;
@property (nonatomic, strong) NSDictionary *flaggedProducts;
@property (nonatomic, strong) NSDictionary *flaggedProductMessage;
@property (nonatomic, strong) SyncOverlayView *syncOverlayView;
@property (nonatomic, strong) UIPopoverListView *poplistview;
@property (nonatomic, strong) NSArray *poNumbersArrayForSelectedProduct;
@property (nonatomic, strong) Product *productSelectedForGlobalSelection;
@property (nonatomic, strong) NSArray *cacheForAllProducts;
@property (nonatomic, strong) NSArray *cacheForAllFilteredProducts;

@property (nonatomic, strong) SKSTableView *table;
@property (nonatomic, strong) RowSectionButton *flaggedProductButton;
@property (nonatomic, strong) RowSectionButton *productStatusButton;

@property (nonatomic, assign) int sectionOpened;
@property (nonatomic, assign) BOOL showAllProductsTapped;
@property (nonatomic, assign) BOOL comingFromContainerScreen;

- (IBAction)searchButtonTouched:(id)sender;
- (IBAction)showAllProductsTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end
