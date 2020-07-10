//
//  OrderData.m
//  DC Insights
//
//  Created by Shyam Ashok on 7/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "OrderData.h"
#import "Inspection.h"
#import "ProgramGroup.h"

@implementation OrderData

@synthesize ID;
@synthesize DCName;
@synthesize ReceivedDateTime;
@synthesize ExpectedDeliveryDateTime;
@synthesize PONumber;
@synthesize POLineNumber;
@synthesize ItemNumber;
@synthesize ItemName;
@synthesize VendorCode;
@synthesize VendorName;
@synthesize QuantityOfCases;
@synthesize POLineNumberValue;
@synthesize CarrierName;
@synthesize ProgramName;
@synthesize FlaggedProduct;
@synthesize FlaggedMessages;
@synthesize loadId;
@synthesize grn;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.DCName = @"";
        self.ReceivedDateTime = @"";
        self.ExpectedDeliveryDateTime = @"";
        self.PONumber = @"";
        self.POLineNumber = @"";
        self.ItemNumber = @"";
        self.ItemName = @"";
        self.VendorCode = @"";
        self.VendorName = @"";
        self.QuantityOfCases = @"";
        self.POLineNumberValue = @"";
        self.CarrierName = @"";
        self.ProgramName = @"";
        self.FlaggedProduct = NO;
        self.grn = @"";
        self.loadId = @"";
        self.CustomerCode = @"";
        self.CustomerName = @"";
        self.Message = @"";
        self.score = @"";
        self.FlaggedMessages = [[NSMutableArray alloc]init];
        self.allFlaggedProductMessages = [[NSMutableArray alloc]init];
    }
    return self;
}

+ (NSString *) getSkuById: (NSString *) productId withProductGroupId: (NSString *) productGroupId withProductGroupsArray: (NSArray *) productGroupsArray {
    if ([productGroupsArray count] > 0) {
    
    }
    return @"";
}

+ (NSArray *) populateAllRatingsData: (NSArray *) ratings withPONumber: (NSString *) poNumber withItemNumber: (NSString *) itemNumber {
    NSMutableArray *finishedRatings = [[NSMutableArray alloc] init];
    NSString *receivedDateTime = [OrderData getReceivedDateTime];
    //NSString *receivedDateTime = [[Inspection sharedInspection] dateTimeForOrderData];
    OrderData *data = [self getOrderDataWithPO: poNumber withItemNumber: itemNumber withTime: receivedDateTime];
    for (Rating *rating in ratings) {
        NSString *field = rating.order_data_field;
        if ([[field uppercaseString] isEqualToString:ORDERDATACARRIERNAME]) {
            rating.ratingAnswerFromUI = data.CarrierName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATADCNAME]) {
            rating.ratingAnswerFromUI = data.DCName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAEXPECTEDDELIVERYDATETIME]) {
            rating.ratingAnswerFromUI = data.ExpectedDeliveryDateTime;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAITEMNAME]) {
            rating.ratingAnswerFromUI = data.ItemName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAITEMNUMBER]) {
            rating.ratingAnswerFromUI = data.ItemNumber;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAPOLINENUMBER]) {
            rating.ratingAnswerFromUI = data.POLineNumber;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAPOLINENUMBERVALUE]) {
            rating.ratingAnswerFromUI = data.POLineNumberValue;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAPONUMBER]) {
            rating.ratingAnswerFromUI = data.PONumber;
            [finishedRatings addObject:rating];
        }  else if ([[field uppercaseString] isEqualToString:ORDERDATAGRN]) {
            rating.ratingAnswerFromUI = data.grn;
                   [finishedRatings addObject:rating];
               }else if ([[field uppercaseString] isEqualToString:ORDERDATAPROGRAMNAME]) {
            rating.ratingAnswerFromUI = data.ProgramName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAQUANTITYOFCASES]) {
            rating.ratingAnswerFromUI = data.QuantityOfCases;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATARECEIVEDDATETIME]) {
            rating.ratingAnswerFromUI = data.ReceivedDateTime;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAVENDORCODE]) {
            rating.ratingAnswerFromUI = data.VendorCode;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAVENDORNAME]) {
            rating.ratingAnswerFromUI = data.VendorName;
            [finishedRatings addObject:rating];
        }else if ([[field uppercaseString] isEqualToString:ORDERDATALOADID]) {
            rating.ratingAnswerFromUI = data.loadId;
            [finishedRatings addObject:rating];
        }else if ([[field uppercaseString] isEqualToString:ORDERDATACUSTOMERNAME]) {
            rating.ratingAnswerFromUI = data.CustomerName;
            [finishedRatings addObject:rating];
        }else {
            [finishedRatings addObject:rating];
        }
    }
    return finishedRatings;
}
+ (NSArray *) populateAllRatingsData: (NSArray *) ratings withGRN: (NSString *) grn withItemNumber: (NSString *) itemNumber {
    NSMutableArray *finishedRatings = [[NSMutableArray alloc] init];
    NSString *receivedDateTime = [OrderData getReceivedDateTime];
    //NSString *receivedDateTime = [[Inspection sharedInspection] dateTimeForOrderData];
    OrderData *data = [self getOrderDataWithGRN: grn withItemNumber: itemNumber withTime: receivedDateTime];
    for (Rating *rating in ratings) {
        NSString *field = rating.order_data_field;
        if ([[field uppercaseString] isEqualToString:ORDERDATACARRIERNAME]) {
            rating.ratingAnswerFromUI = data.CarrierName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATADCNAME]) {
            rating.ratingAnswerFromUI = data.DCName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAEXPECTEDDELIVERYDATETIME]) {
            rating.ratingAnswerFromUI = data.ExpectedDeliveryDateTime;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAITEMNAME]) {
            rating.ratingAnswerFromUI = data.ItemName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAITEMNUMBER]) {
            rating.ratingAnswerFromUI = data.ItemNumber;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAPOLINENUMBER]) {
            rating.ratingAnswerFromUI = data.POLineNumber;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAPOLINENUMBERVALUE]) {
            rating.ratingAnswerFromUI = data.POLineNumberValue;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAPONUMBER]) {
            rating.ratingAnswerFromUI = data.PONumber;
            [finishedRatings addObject:rating];
        }  else if ([[field uppercaseString] isEqualToString:ORDERDATAGRN]) {
            rating.ratingAnswerFromUI = data.grn;
                   [finishedRatings addObject:rating];
               }else if ([[field uppercaseString] isEqualToString:ORDERDATAPROGRAMNAME]) {
            rating.ratingAnswerFromUI = data.ProgramName;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAQUANTITYOFCASES]) {
            rating.ratingAnswerFromUI = data.QuantityOfCases;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATARECEIVEDDATETIME]) {
            rating.ratingAnswerFromUI = data.ReceivedDateTime;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAVENDORCODE]) {
            rating.ratingAnswerFromUI = data.VendorCode;
            [finishedRatings addObject:rating];
        } else if ([[field uppercaseString] isEqualToString:ORDERDATAVENDORNAME]) {
            rating.ratingAnswerFromUI = data.VendorName;
            [finishedRatings addObject:rating];
        }else if ([[field uppercaseString] isEqualToString:ORDERDATALOADID]) {
            rating.ratingAnswerFromUI = data.loadId;
            [finishedRatings addObject:rating];
        }else if ([[field uppercaseString] isEqualToString:ORDERDATACUSTOMERNAME]) {
            rating.ratingAnswerFromUI = data.CustomerName;
            [finishedRatings addObject:rating];
        }else {
            [finishedRatings addObject:rating];
        }
    }
    return finishedRatings;
}
+ (OrderData *) getOrderDataWithPO:(NSString *) poNumber withItemNumber: (NSString *) itemNumber withTime: (NSString *)receivedDateTime {
    OrderData *data = [[OrderData alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[OrderData retrieveOrderDataStatementWithPO: poNumber withItemNumber: itemNumber withTime: receivedDateTime]];
    int countOfCasesTotal = 0;
    while ([results next]) {
        data.DCName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DCNAME]];
        data.ExpectedDeliveryDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DELIVERY_EXPECTED_DATETIME]];
        data.POLineNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER]];
        data.ItemName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NAME]];
        data.VendorName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_NAME]];
        data.VendorCode = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_CODE]];
        data.QuantityOfCases = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.POLineNumberValue = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER_VALUE]];
        data.CarrierName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_CARRIER_NAME]];
        data.ProgramName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PROGRAM_NAME]];
        data.ReceivedDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_RECEIVED_DATETIME]];
        data.PONumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_NUMBER]];
        data.grn = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_GRN]];
        data.ItemNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        data.FlaggedProduct = [self parseBoolFromJson:[results objectForColumnName:COL_ORDER_FLAGGED_PRODUCT]];
        data.Message = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_MESSAGE]];
        data.score = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_SCORE]];
        data.loadId = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_LOAD_ID]];
        data.CustomerName =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_NAME]];
        data.CustomerCode =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_CODE]];
        data.FlaggedMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES]];
        data.allFlaggedProductMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES_ALL]];
        int count = [[self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]] integerValue];
        countOfCasesTotal = countOfCasesTotal + count;
        data.countOfCasesTotalAdded = countOfCasesTotal;
        data.QuantityOfCases = [NSString stringWithFormat:@"%d", countOfCasesTotal];
    }
    [database close];
    return data;
}
+ (OrderData *) getOrderDataWithGRN:(NSString *) grn withItemNumber: (NSString *) itemNumber withTime: (NSString *)receivedDateTime {
    OrderData *data = [[OrderData alloc] init];
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    [database open];
    results = [database executeQuery:[OrderData retrieveOrderDataStatementWithGRN: grn withItemNumber: itemNumber withTime: receivedDateTime]];
    int countOfCasesTotal = 0;
    while ([results next]) {
        data.DCName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DCNAME]];
        data.ExpectedDeliveryDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DELIVERY_EXPECTED_DATETIME]];
        data.POLineNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER]];
        data.ItemName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NAME]];
        data.VendorName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_NAME]];
        data.VendorCode = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_CODE]];
        data.QuantityOfCases = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.POLineNumberValue = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER_VALUE]];
        data.CarrierName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_CARRIER_NAME]];
        data.ProgramName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PROGRAM_NAME]];
        data.ReceivedDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_RECEIVED_DATETIME]];
        data.PONumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_NUMBER]];
        data.grn = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_GRN]];
        data.ItemNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        data.FlaggedProduct = [self parseBoolFromJson:[results objectForColumnName:COL_ORDER_FLAGGED_PRODUCT]];
        data.Message = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_MESSAGE]];
        data.score = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_SCORE]];
        data.loadId = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_LOAD_ID]];
        data.CustomerName =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_NAME]];
        data.CustomerCode =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_CODE]];
        data.FlaggedMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES]];
        data.allFlaggedProductMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES_ALL]];
        int count = [[self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]] integerValue];
        countOfCasesTotal = countOfCasesTotal + count;
        data.countOfCasesTotalAdded = countOfCasesTotal;
        data.QuantityOfCases = [NSString stringWithFormat:@"%d", countOfCasesTotal];
    }
    [database close];
    return data;
}
-(NSMutableArray*) getFlaggedMessagesArrayFromString:(NSString*) string{
    NSArray *array = [string componentsSeparatedByString:@","];
    return [array mutableCopy];
}

+ (NSArray *) getOrderDataForItemNumber: (NSString *) itemNumber {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableArray *orderDataArray = [[NSMutableArray alloc] init];
    [database open];
    results = [database executeQuery:[OrderData retrieveOrderDataStatementForItemNumber: itemNumber]];
    int countOfCasesTotal = 0;
    while ([results next]) {
        OrderData *data = [[OrderData alloc] init];
        data.countForPopup = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.DCName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DCNAME]];
        data.ExpectedDeliveryDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DELIVERY_EXPECTED_DATETIME]];
        data.POLineNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER]];
        data.ItemName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NAME]];
        data.VendorName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_NAME]];
        data.VendorCode = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_CODE]];
        data.QuantityOfCases = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.POLineNumberValue = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER_VALUE]];
        data.CarrierName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_CARRIER_NAME]];
        data.ProgramName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PROGRAM_NAME]];
        data.ReceivedDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_RECEIVED_DATETIME]];
        data.PONumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_NUMBER]];
        data.grn = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_GRN]];
        data.ItemNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        data.loadId = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_LOAD_ID]];
        data.CustomerName =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_NAME]];
        data.CustomerCode =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_CODE]];
        data.FlaggedProduct = [self parseBoolFromJson:[results objectForColumnName:COL_ORDER_FLAGGED_PRODUCT]];
        data.Message = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_MESSAGE]];
        data.score = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_SCORE]];
//        NSString* messageString = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_FLAGGED_MESSAGES]];
//        NSArray *array = [messageString componentsSeparatedByString:@","];
//        data.FlaggedMessages = [array mutableCopy];
//        data.FlaggedMessages = [self parseArrayFromJson:[results objectForColumnName:COL_ORDER_FLAGGED_MESSAGES]];
        data.FlaggedMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES]];
        data.allFlaggedProductMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES_ALL]];
        int count = [[self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]] integerValue];
        countOfCasesTotal = countOfCasesTotal + count;
        data.countOfCasesTotalAdded = countOfCasesTotal;
        data.QuantityOfCases = [NSString stringWithFormat:@"%d", countOfCasesTotal];
        [orderDataArray addObject:data];
    }
    [database close];
    return [orderDataArray copy];
}

+ (NSArray *) getOrderDataForItemNumberWithPONumber: (NSString *) itemNumber withPONumber: (NSString *) ponumber {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableArray *orderDataArray = [[NSMutableArray alloc] init];
    [database open];
    NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber, COL_ORDER_PO_NUMBER, ponumber];
    results = [database executeQuery:poNumberRetrieveStatement];
    int countOfCasesTotal = 0;
    while ([results next]) {
        OrderData *data = [[OrderData alloc] init];
        data.countForPopup = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.DCName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DCNAME]];
        data.ExpectedDeliveryDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DELIVERY_EXPECTED_DATETIME]];
        data.POLineNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER]];
        data.ItemName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NAME]];
        data.VendorName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_NAME]];
        data.VendorCode = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_CODE]];
        data.QuantityOfCases = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.POLineNumberValue = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER_VALUE]];
        data.CarrierName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_CARRIER_NAME]];
        data.ProgramName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PROGRAM_NAME]];
        data.ReceivedDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_RECEIVED_DATETIME]];
        data.PONumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_NUMBER]];
        data.ItemNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        data.FlaggedProduct = [self parseBoolFromJson:[results objectForColumnName:COL_ORDER_FLAGGED_PRODUCT]];
        data.loadId = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_LOAD_ID]];
       data.CustomerName =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_NAME]];
        data.CustomerCode =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_CODE]];
        data.Message = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_MESSAGE]];
        data.score = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_SCORE]];
        data.FlaggedMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES]];
        data.allFlaggedProductMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES_ALL]];
        int count = [[self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]] integerValue];
        countOfCasesTotal = countOfCasesTotal + count;
        data.countOfCasesTotalAdded = countOfCasesTotal;
        data.QuantityOfCases = [NSString stringWithFormat:@"%d", countOfCasesTotal];
        [orderDataArray addObject:data];
    }
    return [orderDataArray copy];
}

+ (NSArray *) getOrderDataForItemNumberWithGRN: (NSString *) itemNumber withGRN: (NSString *) grn {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableArray *orderDataArray = [[NSMutableArray alloc] init];
    [database open];
    NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber, COL_ORDER_GRN, grn];
    results = [database executeQuery:poNumberRetrieveStatement];
    int countOfCasesTotal = 0;
    while ([results next]) {
        OrderData *data = [[OrderData alloc] init];
        data.countForPopup = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.DCName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DCNAME]];
        data.ExpectedDeliveryDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_DELIVERY_EXPECTED_DATETIME]];
        data.POLineNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER]];
        data.ItemName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NAME]];
        data.VendorName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_NAME]];
        data.VendorCode = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_VENDOR_CODE]];
        data.QuantityOfCases = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]];
        data.POLineNumberValue = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_LINE_NUMBER_VALUE]];
        data.CarrierName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_CARRIER_NAME]];
        data.ProgramName = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PROGRAM_NAME]];
        data.ReceivedDateTime = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_RECEIVED_DATETIME]];
        data.PONumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_PO_NUMBER]];
        data.grn = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_GRN]];
        data.ItemNumber = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        data.FlaggedProduct = [self parseBoolFromJson:[results objectForColumnName:COL_ORDER_FLAGGED_PRODUCT]];
        data.loadId = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_LOAD_ID]];
       data.CustomerName =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_NAME]];
        data.CustomerCode =[self parseStringFromJson:[results objectForColumnName:COL_ORDER_CUSTOMER_CODE]];
        data.Message = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_MESSAGE]];
        data.score = [self parseStringFromJson:[results objectForColumnName:COL_ORDER_SCORE]];
        data.FlaggedMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES]];
        data.allFlaggedProductMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[results dataForColumn:COL_ORDER_FLAGGED_MESSAGES_ALL]];
        int count = [[self parseStringFromJson:[results objectForColumnName:COL_ORDER_QUANTITY_OF_CASES]] integerValue];
        countOfCasesTotal = countOfCasesTotal + count;
        data.countOfCasesTotalAdded = countOfCasesTotal;
        data.QuantityOfCases = [NSString stringWithFormat:@"%d", countOfCasesTotal];
        [orderDataArray addObject:data];
    }
    return [orderDataArray copy];
}
/*------------------------------------------------------------------------------
 METHOD: parseStringFromJson
 
 PURPOSE:
 Helper method used to parse a value from JSON data into an NSString.  Handles
 various flavors of "null" representations.
 -----------------------------------------------------------------------------*/
+ (NSString*) parseStringFromJson:(NSString*)key
{
    if (!key) return nil;
    
    id rawValue = key;
    if (!rawValue) return nil;
    if ([rawValue isKindOfClass:[NSNull class]]) return nil;
    if ([rawValue isKindOfClass:[NSString class]] && [rawValue isEqualToString:@"<null>"]) return nil;
    if ([rawValue isKindOfClass:[NSString class]] && [rawValue isEqualToString:@"null"]) return nil;
    if ([rawValue isKindOfClass:[NSString class]] && [rawValue isEqualToString:@"(null)"]) return nil;
    
    if (![rawValue isKindOfClass:[NSString class]]) {
        rawValue = [rawValue stringValue];
    }
    
    return rawValue;
}

+ (BOOL) parseBoolFromJson:(NSString*)data
{
    BOOL theBool = NO;
    
    NSString *boolAsString = [self parseStringFromJson:data];
    if (boolAsString != nil) {
        theBool = [boolAsString boolValue];
    }
    
    return theBool;
}

+ (NSArray*) parseArrayFromJson:(NSDictionary*)data key:(NSString*)key
{
    NSArray *theArray = [NSMutableArray arrayWithCapacity:0];
    
    id rawValue = [data objectForKey:key];
    if (rawValue != nil && [rawValue isKindOfClass:[NSArray class]]) {
        theArray = (NSArray *)rawValue;
    }
    
    return theArray;
}


+ (NSString *) getReceivedDateTime {
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"yyyy-MM-dd"];
//    NSDate *now = [[NSDate alloc] init];
//    NSString *dateString = [format stringFromDate:now];
////    if ([[NSUserDefaultsManager getObjectFromUserDeafults:PORTAL_ENDPOINT] isEqualToString:endPointURL_QA5]) {
////        receivedDateTime = @"2014-06-09";
////    }
    return [[Inspection sharedInspection] dateTimeForOrderData];
}


+ (NSArray *) getAllPONumbers {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableArray *poNumbersWithDates = [NSMutableArray array];
    [database open];
    results = [database executeQuery:[OrderData retrieveStatement]];
    while ([results next]) {
        OrderData *orderData = [[OrderData alloc] init];
        orderData.PONumber = [results stringForColumn:COL_ORDER_PO_NUMBER];
        orderData.grn = [results stringForColumn:COL_ORDER_GRN];
        orderData.ReceivedDateTime = [results stringForColumn:COL_ORDER_RECEIVED_DATETIME];
        orderData.DCName = [results stringForColumn:COL_ORDER_DCNAME];
        orderData.VendorName = [results stringForColumn:COL_ORDER_VENDOR_NAME];
        orderData.ExpectedDeliveryDateTime = [results stringForColumn:COL_ORDER_DELIVERY_EXPECTED_DATETIME];
        orderData.FlaggedProduct = [results intForColumn:COL_ORDER_FLAGGED_PRODUCT];
        orderData.Message = [results stringForColumn:COL_ORDER_MESSAGE];
        orderData.score = [results stringForColumn:COL_ORDER_SCORE];
        orderData.ItemNumber = [results stringForColumn:COL_ORDER_ITEM_NUMBER];
        orderData.loadId = [results stringForColumn:COL_ORDER_LOAD_ID];
        orderData.CustomerName =[results stringForColumn:COL_ORDER_CUSTOMER_NAME];
        [poNumbersWithDates addObject:orderData];
    }
    //NSLog(@"polign %@", poNumbersWithDates);
    [database close];
//    if ([[User sharedUser] userSelectedVendorName] && ![[[User sharedUser] userSelectedVendorName] isEqualToString:@""]) {
//        for (OrderData *orderData in poNumbersWithDates) {
//            if ([orderData.VendorName isEqualToString:[[User sharedUser] userSelectedVendorName]]) {
//                [filteredPOForVendorNames addObject:orderData];
//            }
//        }
//    }
//    if ([filteredPOForVendorNames count] == 0 ) {
//        filteredPOForVendorNames = poNumbersWithDates;
//    }
    return [poNumbersWithDates copy];
}

+ (NSArray *) getAllGRNs {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableArray *poNumbersWithDates = [NSMutableArray array];
    [database open];
    results = [database executeQuery:[OrderData retrieveStatement]];
    while ([results next]) {
        OrderData *orderData = [[OrderData alloc] init];
        orderData.PONumber = [results stringForColumn:COL_ORDER_PO_NUMBER];
        orderData.grn = [results stringForColumn:COL_ORDER_GRN];
        orderData.ReceivedDateTime = [results stringForColumn:COL_ORDER_RECEIVED_DATETIME];
        orderData.DCName = [results stringForColumn:COL_ORDER_DCNAME];
        orderData.VendorName = [results stringForColumn:COL_ORDER_VENDOR_NAME];
        orderData.ExpectedDeliveryDateTime = [results stringForColumn:COL_ORDER_DELIVERY_EXPECTED_DATETIME];
        orderData.FlaggedProduct = [results intForColumn:COL_ORDER_FLAGGED_PRODUCT];
        orderData.Message = [results stringForColumn:COL_ORDER_MESSAGE];
        orderData.score = [results stringForColumn:COL_ORDER_SCORE];
        orderData.ItemNumber = [results stringForColumn:COL_ORDER_ITEM_NUMBER];
        orderData.loadId = [results stringForColumn:COL_ORDER_LOAD_ID];
        orderData.CustomerName =[results stringForColumn:COL_ORDER_CUSTOMER_NAME];
        [poNumbersWithDates addObject:orderData];
    }
    //NSLog(@"polign %@", poNumbersWithDates);
    [database close];
//    if ([[User sharedUser] userSelectedVendorName] && ![[[User sharedUser] userSelectedVendorName] isEqualToString:@""]) {
//        for (OrderData *orderData in poNumbersWithDates) {
//            if ([orderData.VendorName isEqualToString:[[User sharedUser] userSelectedVendorName]]) {
//                [filteredPOForVendorNames addObject:orderData];
//            }
//        }
//    }
//    if ([filteredPOForVendorNames count] == 0 ) {
//        filteredPOForVendorNames = poNumbersWithDates;
//    }
    return [poNumbersWithDates copy];
}

+ (NSString *) retrieveStatement {
    NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_ORDERDATA];
    return poNumberRetrieveStatement;
}

+ (NSSet *) getItemNumbersForPONumberSelected {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableSet *itemNumbers = [NSMutableSet set];
    [database open];
    BOOL isPONone =[[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"];
    BOOL isVendorNone = [[User sharedUser].userSelectedVendorName isEqualToString:@"None"];
    BOOL isCustomerNameNone =[[User sharedUser].userSelectedCustomerName isEqualToString:@"None"];
    //NSLog(@"%@ %@", [Inspection sharedInspection].poNumberGlobal, [User sharedUser].userSelectedVendorName);
    
    NSString* customerName =[User sharedUser].userSelectedCustomerName;
    NSString* poNumber = [Inspection sharedInspection].poNumberGlobal;
    
    if(customerName.length && poNumber.length){
        if(!isCustomerNameNone && !isPONone)
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_PO_NUMBER=? AND ORDER_CUSTOMER_NAME=?",poNumber,customerName];
        else if(isPONone)
            results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_CUSTOMER_NAME=?",customerName];
        else if(isCustomerNameNone)
            results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_PO_NUMBER=?",poNumber];
        while ([results next]) {
            [itemNumbers addObject:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        }
        [database close];
        return [itemNumbers copy];
    }
    
    if ([Inspection sharedInspection].poNumberGlobal.length && [User sharedUser].userSelectedVendorName.length) {
        if(isPONone && !isVendorNone){
            
       //filter by load-id if present
            NSString* selectedLoadId = [User sharedUser].userSelectedLoadId;
            if(selectedLoadId && ![selectedLoadId isEqualToString:@""] && ![selectedLoadId isEqualToString:@"None"])
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_VENDOR_NAME=? AND ORDER_LOAD_ID=?",[User sharedUser].userSelectedVendorName,selectedLoadId];
            else
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_VENDOR_NAME=?", [User sharedUser].userSelectedVendorName];
        }
        else if(!isPONone && isVendorNone)
            results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_PO_NUMBER=?", [Inspection sharedInspection].poNumberGlobal];
        else if(isPONone && isVendorNone){
            //filter by load-id if present
            NSString* selectedLoadId = [User sharedUser].userSelectedLoadId;
            if(selectedLoadId && ![selectedLoadId isEqualToString:@""] && ![selectedLoadId isEqualToString:@"None"])
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_LOAD_ID=?", selectedLoadId];
            else
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA"];
        }
        else
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_PO_NUMBER=? AND ORDER_VENDOR_NAME=?", [Inspection sharedInspection].poNumberGlobal, [User sharedUser].userSelectedVendorName];
    } else if ([Inspection sharedInspection].poNumberGlobal.length) {
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_PO_NUMBER=?", [Inspection sharedInspection].poNumberGlobal];
    } else {
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_VENDOR_NAME=?", [User sharedUser].userSelectedVendorName];
    }
    while ([results next]) {
        [itemNumbers addObject:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
    }
    [database close];
    return [itemNumbers copy];
}

+ (NSSet *) getItemNumbersForGRNSelected {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableSet *itemNumbers = [NSMutableSet set];
    [database open];
    BOOL isGRNNone =[[Inspection sharedInspection].grnGlobal isEqualToString:@"None"];
    BOOL isVendorNone = [[User sharedUser].userSelectedVendorName isEqualToString:@"None"];
    BOOL isCustomerNameNone =[[User sharedUser].userSelectedCustomerName isEqualToString:@"None"];
    //NSLog(@"%@ %@", [Inspection sharedInspection].poNumberGlobal, [User sharedUser].userSelectedVendorName);
    
    NSString* customerName =[User sharedUser].userSelectedCustomerName;
    NSString* grn = [Inspection sharedInspection].grnGlobal;
    
    if(customerName.length && grn.length){
        if(!isCustomerNameNone && !isGRNNone)
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_GRN=? AND ORDER_CUSTOMER_NAME=?",grn,customerName];
        else if(isGRNNone)
            results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_CUSTOMER_NAME=?",customerName];
        else if(isCustomerNameNone)
            results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_GRN=?",grn];
        while ([results next]) {
            [itemNumbers addObject:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        }
        [database close];
        return [itemNumbers copy];
    }
    
    if ([Inspection sharedInspection].grnGlobal.length && [User sharedUser].userSelectedVendorName.length) {
        if(isGRNNone && !isVendorNone){
            
       //filter by load-id if present
            NSString* selectedLoadId = [User sharedUser].userSelectedLoadId;
            if(selectedLoadId && ![selectedLoadId isEqualToString:@""] && ![selectedLoadId isEqualToString:@"None"])
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_VENDOR_NAME=? AND ORDER_LOAD_ID=?",[User sharedUser].userSelectedVendorName,selectedLoadId];
            else
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_VENDOR_NAME=?", [User sharedUser].userSelectedVendorName];
        }
        else if(!isGRNNone && isVendorNone)
            results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_GRN=?", [Inspection sharedInspection].grnGlobal];
        else if(isGRNNone && isVendorNone){
            //filter by load-id if present
            NSString* selectedLoadId = [User sharedUser].userSelectedLoadId;
            if(selectedLoadId && ![selectedLoadId isEqualToString:@""] && ![selectedLoadId isEqualToString:@"None"])
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_LOAD_ID=?", selectedLoadId];
            else
                results = [database executeQuery:@"SELECT * FROM ORDER_DATA"];
        }
        else
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_GRN=? AND ORDER_VENDOR_NAME=?", [Inspection sharedInspection].grnGlobal, [User sharedUser].userSelectedVendorName];
    } else if ([Inspection sharedInspection].grnGlobal.length) {
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_GRN=?", [Inspection sharedInspection].grnGlobal];
    } else {
        results = [database executeQuery:@"SELECT * FROM ORDER_DATA WHERE ORDER_VENDOR_NAME=?", [User sharedUser].userSelectedVendorName];
    }
    while ([results next]) {
        [itemNumbers addObject:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
    }
    [database close];
    return [itemNumbers copy];
}
//TODO convert query to escape all special characters by using the //? format
+ (long)getOrderDataIdForItem:(NSString*)itemNumber{
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    [database open];
    long orderDataId = 0;
    
    NSString* vendorName =[User sharedUser].userSelectedVendorName;
    NSString* poNumber = [Inspection sharedInspection].poNumberGlobal;
    //espace using the "'"
    if([vendorName containsString:@"'"]){
        NSString* nameWithoutApostrophe = [vendorName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        vendorName = nameWithoutApostrophe;
    }
    
    NSString* query;
    if((![poNumber  isEqual: @""]) && (poNumber != nil))
        query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@=%@", TBL_ORDERDATA, COL_ORDER_PO_NUMBER, [Inspection sharedInspection].poNumberGlobal, COL_ORDER_VENDOR_NAME, vendorName, COL_ORDER_ITEM_NUMBER, itemNumber];
    else
        query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@' AND %@=%@", TBL_ORDERDATA, COL_ORDER_GRN, [Inspection sharedInspection].grnGlobal, COL_ORDER_VENDOR_NAME, vendorName, COL_ORDER_ITEM_NUMBER, itemNumber];
    
    //if vendorname is blank for any reason
    if(!vendorName || [vendorName isEqualToString:@""]){
        query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_PO_NUMBER, [Inspection sharedInspection].poNumberGlobal, COL_ORDER_ITEM_NUMBER, itemNumber];
    }
    
    results = [database executeQuery:query];
    while ([results next]) {
        orderDataId = [results intForColumn:COL_ORDER_ID];
    }
    [database close];
    return orderDataId;
}


+ (NSSet *) getAllItemNumbers {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    NSMutableSet *itemNumbers = [NSMutableSet set];
    [database open];
    results = [database executeQuery:@"SELECT * FROM ORDER_DATA"];
    while ([results next]) {
        [itemNumbers addObject:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
    }
    [database close];
    return [itemNumbers copy];
}

+ (NSString *) retrieveItemNumberStatement {
    NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_PO_NUMBER, [Inspection sharedInspection].poNumberGlobal, COL_ORDER_VENDOR_NAME, [User sharedUser].userSelectedVendorName];
    NSLog(@"%@", poNumberRetrieveStatement);
    return poNumberRetrieveStatement;
}

+ (NSString *) retrieveOrderDataStatementWithPO:(NSString *) poNumber withItemNumber: (NSString *) itemNumber withTime: (NSString *)receivedDateTime {
    NSString *poNumberRetrieveStatement = @"";
    
    if ([poNumber length] && [receivedDateTime length]) {
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND (%@='%@' OR %@='%@') AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber, COL_ORDER_RECEIVED_DATETIME, receivedDateTime, COL_ORDER_DELIVERY_EXPECTED_DATETIME, receivedDateTime, COL_ORDER_PO_NUMBER, poNumber];
    } else {
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber];
    }
    
    //DI-1831
    BOOL isPONone =[[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"];
    BOOL isVendorNone = [[User sharedUser].userSelectedVendorName isEqualToString:@"None"];
    
    if(isPONone && !isVendorNone)
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber,COL_ORDER_VENDOR_NAME, [User sharedUser].userSelectedVendorName];
    else if(!isPONone && isVendorNone)
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber,COL_ORDER_PO_NUMBER, [Inspection sharedInspection].poNumberGlobal];
    else if(isPONone && isVendorNone)
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber];
    
    //NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_ORDERDATA,COL_ORDER_PO_NUMBER, poNumber];
    return poNumberRetrieveStatement;
}
+ (NSString *) retrieveOrderDataStatementWithGRN:(NSString *) grn withItemNumber: (NSString *) itemNumber withTime: (NSString *)receivedDateTime {
    NSString *poNumberRetrieveStatement = @"";
    
    if ([grn length] && [receivedDateTime length]) {
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND (%@='%@' OR %@='%@') AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber, COL_ORDER_RECEIVED_DATETIME, receivedDateTime, COL_ORDER_DELIVERY_EXPECTED_DATETIME, receivedDateTime, COL_ORDER_GRN, grn];
    } else {
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber];
    }
    
    //DI-1831
    BOOL isGRNNone =[[Inspection sharedInspection].grnGlobal isEqualToString:@"None"];
    BOOL isVendorNone = [[User sharedUser].userSelectedVendorName isEqualToString:@"None"];
    
    if(isGRNNone && !isVendorNone)
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber,COL_ORDER_VENDOR_NAME, [User sharedUser].userSelectedVendorName];
    else if(!isGRNNone && isVendorNone)
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber,COL_ORDER_GRN, [Inspection sharedInspection].grnGlobal];
    else if(isGRNNone && isVendorNone)
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber];
    
    //NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_ORDERDATA,COL_ORDER_PO_NUMBER, poNumber];
    return poNumberRetrieveStatement;
}
+ (NSString *) retrieveOrderDataStatementForItemNumber: (NSString *) itemNumber {
    NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber];
    //DI-1831
    BOOL isPONone =[[Inspection sharedInspection].poNumberGlobal isEqualToString:@"None"];
    BOOL isVendorNone = [[User sharedUser].userSelectedVendorName isEqualToString:@"None"];
    NSString *poNumber = [Inspection sharedInspection].poNumberGlobal;
    if(isPONone && !isVendorNone)
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber,COL_ORDER_VENDOR_NAME, [User sharedUser].userSelectedVendorName];
    else if(!isPONone && isVendorNone){
        if((![poNumber  isEqual: @""]) && (poNumber != nil)){
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber,COL_ORDER_PO_NUMBER, [Inspection sharedInspection].poNumberGlobal];
        }
        else{
        poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@'", TBL_ORDERDATA, COL_ORDER_ITEM_NUMBER, itemNumber,COL_ORDER_GRN, [Inspection sharedInspection].grnGlobal];
        }
    }
    //NSString *poNumberRetrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@", TBL_ORDERDATA,COL_ORDER_PO_NUMBER, poNumber];
    return poNumberRetrieveStatement;
}

+ (BOOL) orderDataExistsInDB{
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    [database open];
    BOOL hasResults = NO;
    results = [database executeQuery:@"SELECT * FROM ORDER_DATA"];
    while ([results next]) {
        //[itemNumbers addObject:[results objectForColumnName:COL_ORDER_ITEM_NUMBER]];
        hasResults = YES;
    }
    [database close];
    return hasResults;
}

+(void) saveOrderDataStatusPref:(BOOL)status{
    [NSUserDefaultsManager saveBOOLToUserDefaults:status withKey:ORDER_DATA_PRESENT];
}

+(BOOL) checkOrderDataStatusPref{
    return [NSUserDefaultsManager getBOOLFromUserDeafults:ORDER_DATA_PRESENT];
}

+ (void) clearAllOrderData{
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    FMResultSet *results;
    [database open];
    [database executeUpdate:@"DELETE FROM ORDER_DATA"];
    [database close];
}

@end
