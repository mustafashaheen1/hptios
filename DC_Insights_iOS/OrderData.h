//
//  OrderData.h
//  DC Insights
//
//  Created by Shyam Ashok on 7/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "JSONMOdel.h"
#import "DCBaseEntity.h"

@protocol OrderData
@end

@interface OrderData : JSONModel
@property (nonatomic, assign) int ID;
@property (nonatomic, strong) NSString *DCName;
@property (nonatomic, strong) NSString *ReceivedDateTime;
@property (nonatomic, strong) NSString *ExpectedDeliveryDateTime;
@property (nonatomic, strong) NSString *PONumber;
@property (nonatomic, strong) NSString *grn;
@property (nonatomic, strong) NSString *POLineNumber;
@property (nonatomic, strong) NSString *ItemNumber;
@property (nonatomic, strong) NSString *ItemName;
@property (nonatomic, strong) NSString *VendorCode;
@property (nonatomic, strong) NSString *VendorName;
@property (nonatomic, strong) NSString *CustomerCode;
@property (nonatomic, strong) NSString *CustomerName;
@property (nonatomic, strong) NSString *QuantityOfCases;
@property (nonatomic, strong) NSString *POLineNumberValue;
@property (nonatomic, strong) NSString *CarrierName;
@property (nonatomic, strong) NSString *ProgramName;
@property (nonatomic, strong) NSString *loadId;
@property (nonatomic, assign) int countOfCasesTotalAdded;
@property (nonatomic, strong) NSString *countForPopup;
@property (nonatomic, assign) BOOL FlaggedProduct;
@property (nonatomic, strong) NSString *Message;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSMutableArray *FlaggedMessages;
@property (nonatomic, strong) NSMutableArray *allFlaggedProductMessages;

//@property (nonatomic, strong) NSMutableArray *FlaggedMessagesProcessed;

+ (NSArray *) getAllPONumbers;
+ (NSArray *) getAllGRNs;
+ (NSSet *) getItemNumbersForPONumberSelected;
+ (NSSet *) getItemNumbersForGRNSelected;
+ (NSSet *) getAllItemNumbers;
+ (NSString *) getSkuById: (NSString *) productId withProductGroupId: (NSString *) productGroupId withProductGroupsArray: (NSArray *) productGroupsArray;
+ (NSArray *) populateAllRatingsData: (NSArray *) ratings withPONumber: (NSString *) poNumber withItemNumber: (NSString *) itemNumber;
+ (NSArray *) populateAllRatingsData: (NSArray *) ratings withGRN: (NSString *) grn withItemNumber: (NSString *) itemNumber;
+ (NSString *) getReceivedDateTime;
+ (OrderData *) getOrderDataWithPO:(NSString *) poNumber withItemNumber: (NSString *) itemNumber withTime: (NSString *)receivedDateTime;
+ (OrderData *) getOrderDataWithGRN:(NSString *) grn withItemNumber: (NSString *) itemNumber withTime: (NSString *)receivedDateTime;
+ (NSArray *) getOrderDataForItemNumber: (NSString *) itemNumber;
+ (NSArray *) getOrderDataForItemNumberWithPONumber: (NSString *) itemNumber withPONumber: (NSString *) ponumber;
+ (NSArray *) getOrderDataForItemNumberWithGRN: (NSString *) itemNumber withGRN: (NSString *) grn;
+ (long)getOrderDataIdForItem:(NSString*)itemNumber;
+ (BOOL) orderDataExistsInDB;
+(BOOL) checkOrderDataStatusPref;
+(void) saveOrderDataStatusPref:(BOOL)status;
+ (void) clearAllOrderData;
/*
+(NSDictionary*)getOrderDataKeyAndClassMemberMapping;
+(NSArray*)getOrderDataInMemoryWithQuery:(NSDictionary*)queryDictionary;
+(NSArray*)getOrderDataForItemNumbers:(NSArray*)productSkus;
 */
@end
