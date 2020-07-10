//
//  OrderDataAPI.m
//  DC Insights
//
//  Created by Shyam Ashok on 7/23/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "OrderDataAPI.h"
#import "JSONModel.h"
#import "OrderData.h"
#import "User.h"
#import "SyncManager.h"

@interface OrderDataPagination: JSONModel
@property (nonatomic, assign) int limit;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) int total_pages;
@property (nonatomic, assign) int total;
@end

@implementation OrderDataPagination
@synthesize limit,page,total_pages,total;
- (id)init
{
    self = [super init];
    if (self) {
        self.limit = 0;
        self.total = 0;
        self.total_pages = 0;
        self.page = 0;
    }
    return self;
}
@end

@interface OrderApiData: JSONModel
@property (nonatomic, strong) OrderDataPagination *pagination;
@property (nonatomic, strong) NSArray<OrderData> *result;
@end

@implementation OrderApiData
@synthesize pagination;
- (id)init
{
    self = [super init];
    if (self) {
        self.pagination = [[OrderDataPagination alloc] init];
        NSArray *resultsLocal = [[NSArray alloc] init];
        self.result = (NSArray <OrderData>*)resultsLocal;
    }
    return self;
}
@end

@interface OrderDataAPI()
@property (nonatomic, strong) OrderApiData *orderApiData;
@end

@implementation OrderDataAPI

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.jsonOrderDataPages = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - CallToServer


// Call to Stores

- (void)orderDataCallwithAllTheBlocks:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block
             withSyncOverlayView:(SyncOverlayView *) syncOverlayView {

    [self addSplunkLog:[NSString stringWithFormat:@"\nOrderDataAPI_Log-Insights-iOS download begin for %@ with DeviceId %@", [User sharedUser].email, [DeviceManager getDeviceID]]];
    [self addSplunkLog:[DeviceManager getConnectivityStatusLog]];
    self.syncOverlayViewGlobal = syncOverlayView;
    __block int currentPageNumber = 1;
    NSDictionary *parameters = [self getParametersforPageNo:currentPageNumber];
    [self addSplunkLog:[NSString stringWithFormat:@"Requesting Page # 1 with parameters: %@",parameters]];
    [self orderDataCallWithParameters:parameters forPage:currentPageNumber withRetryCount:0 withBlock:^ (BOOL isSuccess, id JSON, NSError *error){
        if(isSuccess){
            [self.syncOverlayViewGlobal showOnlyHeaderMessage:@"Processing Data...."];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self addSplunkLog:[NSString stringWithFormat:@"Processing OrderData"]];
                [self insertRowDataAndCleanupDuplicates];
                [self addSplunkLog:[NSString stringWithFormat:@"Processing OrderData Complete"]];
                //send logs to backend
                [self sendLogsToBackend];
                dispatch_async(dispatch_get_main_queue(), ^{
                   block(YES,self.jsonOrderDataPages,error);
                });
            });
        }else{
            [self addSplunkLog:[NSString stringWithFormat:@"OrderData dowload Failed. Error %@",error.localizedDescription]];
            [self sendLogsToBackend];
            block(NO,self.jsonOrderDataPages,error);
        }
    }];
}

- (void) orderDataCallWithParameters:(NSDictionary*)parameters forPage:(int)pageNo withRetryCount:(int)retryCount withBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block {
    //NSLog(@"OrderDataAPI.m - calling orderData with parameters: %@ for pageNo: %d",parameters,pageNo);
    //[self addSplunkLog:[NSString stringWithFormat:@"Requesting Page # %d",pageNo]];
    __weak OrderDataAPI* weakSelf = self;
    __block int retryCountForPage = retryCount;
    NSString *device_id = [DeviceManager getDeviceID];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    NSString *api_name = [NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@", OrderDatas, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]];
    [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@", OrderDatas, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
            BOOL successWrite= [self writeDataToFile:[NSString stringWithFormat:@"%@%d.json", orderDataFilePath, pageNo] withContents:JSON];
            id JSONLocal = [self readDataFromFile:[NSString stringWithFormat:@"%@%d.json", orderDataFilePath, pageNo]];
            NSLog(@"response received for pageNo:%d is %@",pageNo,JSONLocal);
            OrderApiData *orderApiData = [[OrderApiData alloc] init];
            orderApiData = [self setAttributesFromMap:JSONLocal];
            if (orderApiData) {
                [self.jsonOrderDataPages addObjectsFromArray:orderApiData.result];
                [self addSplunkLog:[NSString stringWithFormat:@"Response success for Page # %d",pageNo]];
            }
        if(pageNo == 1){
            int totalNumberOfPages = orderApiData.pagination.total_pages;
            float value = totalNumberOfPages;
            float divide = 1.0/value;
            self.syncOverlayViewGlobal.pageNo = divide;
            self.totalNumberOfPagesToBeDownloaded = totalNumberOfPages;
            self.totalNumberOfData = orderApiData.pagination.total;
            [self addSplunkLog:[NSString stringWithFormat:@"Total pages # %d",totalNumberOfPages]];
        }
        //Error Handling
        if(self.totalNumberOfPagesToBeDownloaded == 0){
            NSError *error = [[NSError alloc] initWithDomain:@"Insights" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Order-Data returned empty results."}];
            [self addSplunkLog:[NSString stringWithFormat:@"OrderData dowload Failed. Error %@",error.localizedDescription]];
            block(NO, self.jsonOrderDataPages, error);
            return;
        }
        if(self.totalNumberOfPagesToBeDownloaded == -1){
            NSString* jsonResponse = [NSString stringWithFormat:@"Error Response for page %d: \n%@",pageNo,JSONLocal];
            NSError *error = [[NSError alloc] initWithDomain:@"Insights" code:200 userInfo:@{ NSLocalizedDescriptionKey:jsonResponse}];
            [self addSplunkLog:[NSString stringWithFormat:@"OrderData dowload Failed. Error %@",error.localizedDescription]];
            block(NO, self.jsonOrderDataPages, error);
            return;
        }
            
        int nextPage = pageNo+1;
        if(nextPage <= self.totalNumberOfPagesToBeDownloaded){
            [self.syncOverlayViewGlobal updateProgressWithPageNo];
            NSDictionary *parameters = [self getParametersforPageNo:nextPage];
            [weakSelf orderDataCallWithParameters:parameters forPage:nextPage withRetryCount:retryCountForPage withBlock:block];
        }else{
            [self addSplunkLog:[NSString stringWithFormat:@"All Pages downloaded - total %d of %d",pageNo,self.totalNumberOfPagesToBeDownloaded]];
             block(successWrite, self.jsonOrderDataPages, nil); //download complete
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self addSplunkLog:[NSString stringWithFormat:@"Failed downloading Page # %d with error: %@",pageNo,error.localizedDescription]];
        if(retryCountForPage<RETRY_LIMIT){
            //NSLog(@"Retrying - count %d",retryCountForPage);
            [self addSplunkLog:[NSString stringWithFormat:@"Retry Count: %d",retryCountForPage]];
            retryCountForPage++;
            NSDictionary *parameters = [self getParametersforPageNo:pageNo];
            [weakSelf orderDataCallWithParameters:parameters forPage:pageNo withRetryCount:retryCountForPage withBlock:block];
        }
        else{
            [self addSplunkLog:[NSString stringWithFormat:@"FAILED: Max retries(%d) completed for page: %d",RETRY_LIMIT,retryCountForPage]];
                block(NO, self.jsonOrderDataPages, error);
        }

    }];
}

-(void)addSplunkLog:(NSString*)message{
    [[User sharedUser] addTrackingLog:message];
    NSLog(@"%@",message);
}

-(void)sendLogsToBackend{
    SyncManager *syncManager = [[SyncManager alloc] init];
    [syncManager sendLogsToBackend];
}


-(NSDictionary*)getParametersforPageNo:(int)pageNo {
    NSString *timeLocal =[DeviceManager getCurrentTimeString];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:OrderDataLimitPerCall forKey:@"responseLimit"];
    [parameters setObject:[NSNumber numberWithInt:pageNo] forKey:@"getPage"];
    [parameters setObject:timeLocal forKey:@"currentTimeStamp"];
    [parameters setObject:OrderDataDefaultNumberOfDays forKey:@"daysBefore"];
    int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
    NSString *timeZoneOffsetString = [NSString stringWithFormat:@"%+d",timeZoneOffset];
    [parameters setObject:timeZoneOffsetString forKey:@"tzOffset"];
    NSString* storeName = [NSUserDefaultsManager getObjectFromUserDeafults:STORE_NAME];
    [parameters setObject:storeName forKey:@"location"];
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER]) {
        [parameters setObject:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER] forKey:@"daysBefore"];
    }
    [parameters setObject:OrderDataDefaultNumberOfDays forKey:@"daysAfter"];
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER]) {
        [parameters setObject:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER] forKey:@"daysAfter"];
    }
    return parameters;
}

-(NSString*)sanitizeItemNumber:(NSString*)itemNumber {
    NSString* sanitizedItemNumber = itemNumber;
    if(itemNumber && [itemNumber containsString:@"-"]){
        int index = [itemNumber rangeOfString:@"-"].location;
        sanitizedItemNumber = [itemNumber substringToIndex:index];
    }
    return sanitizedItemNumber;
}

-(void)insertRowDataAndCleanupDuplicates{
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    [database open];
    //NSLog(@"Inserting Pages in DB %d", [self.jsonOrderDataPages count]);
    for (int i=0; i < [self.jsonOrderDataPages count]; i++) {
        OrderData *orderData = [self.jsonOrderDataPages objectAtIndex:i];
        NSData *flagMsg = [NSKeyedArchiver archivedDataWithRootObject:orderData.FlaggedMessages];
         NSData *allFlagMsgs = [NSKeyedArchiver archivedDataWithRootObject:orderData.allFlaggedProductMessages];
        if(orderData.ID > 0){
       [database executeUpdate:@"insert into ORDER_DATA (ORDER_ID,ORDER_DC_NAME, ORDER_RECEIVED_DATETIME, ORDER_DELIVERY_EXPECTED_DATETIME, ORDER_PO_NUMBER, ORDER_GRN, ORDER_PO_LINE_NUMBER, ORDER_ITEM_NUMBER, ORDER_ITEM_NAME, ORDER_VENDOR_CODE, ORDER_VENDOR_NAME, ORDER_QUANTITY_OF_CASES, ORDER_PO_LINE_NUMBER_VALUE, ORDER_CARRIER_NAME, ORDER_PROGRAM_NAME, ORDER_FLAGGED_PRODUCT, ORDER_MESSAGE, ORDER_SCORE,ORDER_FLAGGED_MESSAGES,ORDER_FLAGGED_MESSAGES_ALL,ORDER_LOAD_ID,ORDER_CUSTOMER_CODE,ORDER_CUSTOMER_NAME) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d", orderData.ID],orderData.DCName, orderData.ReceivedDateTime, orderData.ExpectedDeliveryDateTime, orderData.PONumber, orderData.grn, orderData.POLineNumber, orderData.ItemNumber, orderData.ItemName, orderData.VendorCode, orderData.VendorName,  orderData.QuantityOfCases, orderData.POLineNumberValue, orderData.CarrierName, orderData.ProgramName, [NSString stringWithFormat:@"%d", orderData.FlaggedProduct?1:0], orderData.Message,orderData.score, flagMsg,allFlagMsgs,orderData.loadId,orderData.CustomerCode,orderData.CustomerName];
        }
    }
    
    //cleanup
    //when customer updates the count of cases for any order-data, then a new row is inserted - the old one needs to be removed and keep the latest
    // 10/2016 updated to remove all rows other than MAX
    NSString* cleanUpQuery = [NSString stringWithFormat:@"select ORDER_PO_NUMBER,ORDER_ITEM_NUMBER,ORDER_VENDOR_NAME, ORDER_DELIVERY_EXPECTED_DATETIME, MAX(ORDER_ID) as ORDER_ID, count(*) as cnt from ORDER_DATA group by ORDER_PO_NUMBER,ORDER_ITEM_NUMBER,ORDER_VENDOR_NAME, ORDER_DELIVERY_EXPECTED_DATETIME"];
    FMResultSet *resultsGroupRatings;
    resultsGroupRatings = [database executeQuery:cleanUpQuery];
    NSMutableArray* orderDataIdsToRemove = [[NSMutableArray alloc]init];
    while ([resultsGroupRatings next]) {
        NSError *err = nil;
        [orderDataIdsToRemove addObject:[resultsGroupRatings stringForColumn:COL_ORDER_ID]];
    }
    if([orderDataIdsToRemove count]>0){
        NSString *joinedComponents = [orderDataIdsToRemove componentsJoinedByString:@","];
        NSString *deleteQuery = [NSString stringWithFormat:@"Delete from ORDER_DATA where ORDER_ID NOT in (%@)",joinedComponents];
        [database executeUpdate:deleteQuery];
    }
    [database close];
}



#pragma mark - Old OrderData code
/*
- (void)orderDataCallWithBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block withSyncOverlayView:(SyncOverlayView *) syncOverlayView {
    [User sharedUser].trackingLog = @"";
    [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"OrderDataAPI_Log-Insights-iOS download begin for %@", [User sharedUser].email]];
    NSString *timeLocal = [DeviceManager getCurrentTimeString];
    NSLog(@"Program Name: %@", [NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName]);
//    if ([[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
//        timeLocal = [DeviceManager getTimeForAldi];
//    }
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:OrderDataLimitPerCall forKey:@"responseLimit"];
    [parameters setObject:@"1" forKey:@"getPage"];
    [parameters setObject:timeLocal forKey:@"currentTimeStamp"];
    [parameters setObject:OrderDataDefaultNumberOfDays forKey:@"daysBefore"];
    // Adding tzOffset and location parameters
    
//    if (![[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
//        // since ALDI already has a hard-coded offset - comment out until the tzOffset get deployed to production
//        int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
//        [parameters setObject:[NSNumber numberWithInt:timeZoneOffset] forKey:@"tzOffset"];
//    }
    //uncomment when order-data api location/tzoffset are deployed to production
    int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
    NSString *timeZoneOffsetString = [NSString stringWithFormat:@"%+d",timeZoneOffset];
    [parameters setObject:timeZoneOffsetString forKey:@"tzOffset"];
    
    NSString* storeName = [NSUserDefaultsManager getObjectFromUserDeafults:STORE_NAME];
    [parameters setObject:storeName forKey:@"location"];
    
    self.syncOverlayViewGlobal = syncOverlayView;
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER]) {
        [parameters setObject:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER] forKey:@"daysBefore"];
    }
    [parameters setObject:OrderDataDefaultNumberOfDays forKey:@"daysAfter"];
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER]) {
        [parameters setObject:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER] forKey:@"daysAfter"];
    }
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER] || [NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER]) {
        [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"DaysBefore= %@ / DaysAfter= %@", [NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER], [NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER]]];
    }

    
    if ([parameters count] > 0) {
        NSLog(@"OrderDataAPI.m - calling orderData with parameters: %@",parameters);
       //  NSLog(@"order-data params are: @%@", parameters);
        [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@", OrderDatas, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
            id JSONLocal;
            BOOL successWrite = NO;
            if (JSON) {
                successWrite = [self writeDataToFile:[NSString stringWithFormat:@"%@1.json", orderDataFilePath] withContents:JSON];
            } else {
                block(NO, self.jsonOrderDataPages, nil);
            }
            if (successWrite) {
                JSONLocal = [self readDataFromFile:[NSString stringWithFormat:@"%@1.json", orderDataFilePath]];
                NSLog(@"OrderDataAPI.m - OrderData Response Received For 1");
            }
            //NSLog(@"OrderData %@", JSONLocal);
            OrderApiData *orderApiDataLocal = [[OrderApiData alloc] init];
            orderApiDataLocal = [self setAttributesFromMap:JSONLocal];
            if (orderApiDataLocal) {
                [self.jsonOrderDataPages addObjectsFromArray:orderApiDataLocal.result];
            }
            int totalNumberOfPages = orderApiDataLocal.pagination.total_pages;
            float value = totalNumberOfPages;
            float divide = 1.0/value;
            self.syncOverlayViewGlobal.pageNo = divide;
            self.totalNumberOfPagesToBeDownloaded = totalNumberOfPages;
            self.totalNumberOfData = orderApiDataLocal.pagination.total;
            NSLog([NSString stringWithFormat:@"OrderData total number of pages %d", totalNumberOfPages]);
            [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"OrderData total number of pages %d", totalNumberOfPages]];
            [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"OrderData call success for pageNo 1"]];
            if (totalNumberOfPages == 0) {
                if (block) {
                    block(YES, self.jsonOrderDataPages, nil);
                }
            } else if (totalNumberOfPages == 1) { // if there is only 1 page of order-data
                if (block) {
                    if(successWrite && [self downloadedAllPages:1])
                    block(YES, self.jsonOrderDataPages, nil);
                }
            }
            else if (totalNumberOfPages == -1) {
                if (block) {
                    block(NO, self.jsonOrderDataPages, nil);
                }
            } else {
                for (int i=2; i <= totalNumberOfPages; i++) {
                    [self orderDataCallWithPageNumber:i withBlock:^ (BOOL isSuccess, NSArray *array, NSError *error) {
                        if (error) {
                            block(NO, self.jsonOrderDataPages, error);
                        } else {
                            if (isSuccess && [self downloadedAllPages:i]) {
                                block(YES, self.jsonOrderDataPages, nil);
                            } else if(!isSuccess){
                                block(NO, self.jsonOrderDataPages, error);
                            }
                        }
                    } withTime: timeLocal];
                }
            }
            //NSLog(@"%@", orderApiDataLocal);

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) {
                NSLog(@"OrderDataAPI.m - OrderData Response FAILED For 1 with error %@",error.localizedDescription);
                [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"OrderData first call failure %@", error.localizedDescription]];
                block(NO, self.jsonOrderDataPages, error);
            }
        }];
    }
}
 */
- (OrderApiData *) setAttributesFromMap: (NSDictionary *) dictionaryJSON {
    OrderApiData *orderApiData = [[OrderApiData alloc] init];
    OrderDataPagination *pagination = [[OrderDataPagination alloc] init];
    NSDictionary *paginationDict = [dictionaryJSON objectForKey:@"pagination"];
    pagination.limit = [self parseIntegerFromJson:paginationDict key:@"limit"];
    pagination.total = [self parseIntegerFromJson:paginationDict key:@"total"];
    pagination.total_pages = [self parseIntegerFromJson:paginationDict key:@"total_pages"];
    pagination.page = [self parseIntegerFromJson:paginationDict key:@"page"];
    orderApiData.pagination = pagination;
    NSArray *resultsArray = [dictionaryJSON objectForKey:@"result"];
    NSMutableArray *resultsArrayObject = [[NSMutableArray alloc] init];
    for (NSDictionary *orderDataDict in resultsArray) {
        OrderData *orderData = [[OrderData alloc] init];
        orderData.ID = [self parseIntegerFromJson:orderDataDict key:@"ID"];
        //NSLog(@"Order-DATA id is: %d", orderData.ID);
        orderData.DCName = [self parseStringFromJson:orderDataDict key:@"DCName"];
//        NSDate *dateReceieved  = [self parseDateFromJson:orderDataDict key:@"ReceivedDateTime"];
//        NSDate *dateExpected  = [self parseDateFromJson:orderDataDict key:@"ExpectedDeliveryDateTime"];
        orderData.ReceivedDateTime = [self parseStringFromJson:orderDataDict key:@"ReceivedDateTime"];
        orderData.ExpectedDeliveryDateTime = [self parseStringFromJson:orderDataDict key:@"ExpectedDeliveryDateTime"];
        orderData.PONumber = [self parseStringFromJson:orderDataDict key:@"PONumber"];
        NSInteger temp = [self parseIntegerFromJson:orderDataDict key:@"GRN"];
        orderData.grn = [@(temp) stringValue];
        orderData.POLineNumber = [self parseStringFromJson:orderDataDict key:@"POLineNumber"];
        orderData.ItemNumber = [self parseStringFromJson:orderDataDict key:@"ItemNumber"];
        orderData.ItemName = [self parseStringFromJson:orderDataDict key:@"ItemName"];
        orderData.VendorCode = [self parseStringFromJson:orderDataDict key:@"VendorCode"];
        orderData.VendorName = [self parseStringFromJson:orderDataDict key:@"VendorName"];
        //if (!orderData.VendorName)
          //  orderData.VendorName = @"";
        orderData.QuantityOfCases = [self parseStringFromJson:orderDataDict key:@"QuantityOfCases"];
        orderData.POLineNumberValue = [self parseStringFromJson:orderDataDict key:@"POLineNumberValue"];
        orderData.CarrierName = [self parseStringFromJson:orderDataDict key:@"CarrierName"];
        orderData.ProgramName = [self parseStringFromJson:orderDataDict key:@"ProgramName"];
        orderData.FlaggedProduct = [self parseBoolFromJson:orderDataDict key:@"FlaggedProduct"];
        orderData.Message = [self parseStringFromJson:orderDataDict key:@"Message"];
        orderData.score = [self parseStringFromJson:orderDataDict key:@"score"];
        orderData.FlaggedMessages = [orderDataDict objectForKey:@"FlaggedMessages"];
        orderData.allFlaggedProductMessages = [orderDataDict objectForKey:@"FlaggedProductMessages"];
         orderData.loadId = [self parseStringFromJson:orderDataDict key:@"LoadID"];
        orderData.CustomerName = [self parseStringFromJson:orderDataDict key:@"CustomerName"];
        orderData.CustomerCode = [self parseStringFromJson:orderDataDict key:@"CustomerCode"];
        [resultsArrayObject addObject:orderData];
    }
    orderApiData.result = [resultsArrayObject copy];
    return orderApiData;
}
/*
- (void) orderDataCallWithPageNumber:(int) pageNo withBlock:(void (^)(BOOL isSuccess, NSArray *array, NSError *error))block withTime: (NSString *) time {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *timeLocal = [DeviceManager getCurrentTimeString];
//    if ([[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
//        timeLocal = [DeviceManager getTimeForAldi];
//    }
    [parameters setObject:OrderDataLimitPerCall forKey:@"responseLimit"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageNo] forKey:@"getPage"];
    [parameters setObject:timeLocal forKey:@"currentTimeStamp"];
    [parameters setObject:OrderDataDefaultNumberOfDays forKey:@"daysBefore"];
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER]) {
        [parameters setObject:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSBEFORENUMBER] forKey:@"daysBefore"];
    }
    [parameters setObject:OrderDataDefaultNumberOfDays forKey:@"daysAfter"];
    if ([NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER]) {
        [parameters setObject:[NSUserDefaultsManager getObjectFromUserDeafults:DAYSAFTERNUMBER] forKey:@"daysAfter"];
    }
    // Adding tzOffset and location parameters
    
//    if (![[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"]) {
//            // since ALDI already has a hard-coded offset - comment out until the tzOffset get deployed to production
//        int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
//        [parameters setObject:[NSNumber numberWithInt:timeZoneOffset] forKey:@"tzOffset"];
//    }
    //uncomment when order-data api location/tzoffset are deployed to production
    int timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
    NSString *timeZoneOffsetString = [NSString stringWithFormat:@"%+d",timeZoneOffset];
    [parameters setObject:timeZoneOffsetString forKey:@"tzOffset"];

    NSString* storeName = [NSUserDefaultsManager getObjectFromUserDeafults:STORE_NAME];
    [parameters setObject:storeName forKey:@"location"];
    
    if ([parameters count] > 0) {
        NSLog(@"OrderDataAPI.m - calling orderData with parameters: %@",parameters);
        //NSLog(@"order-data params paginated are: @%@", parameters);
        [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"%@?auth_token=%@&device_id=%@", OrderDatas, [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
            id JSONLocal;
            BOOL successWrite = NO;
            [self.syncOverlayViewGlobal updateProgressWithPageNo];
            if (JSON) {
                successWrite= [self writeDataToFile:[NSString stringWithFormat:@"%@%d.json", orderDataFilePath, pageNo] withContents:JSON];
            } else {
                block(NO, self.jsonOrderDataPages, nil);
            }
            if (successWrite) {
                JSONLocal = [self readDataFromFile:[NSString stringWithFormat:@"%@%d.json", orderDataFilePath, pageNo]];
            }
            //NSLog(@"OrderData %@", JSONLocal);
            if (successWrite) {
                [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"OrderData call success for pageNo %d", pageNo]];
                NSLog(@"OrderDataAPI.m - OrderData Response Received For %d", pageNo);
                OrderApiData *orderApiData = [[OrderApiData alloc] init];
                orderApiData = [self setAttributesFromMap:JSONLocal];
                if (orderApiData) {
                    [self.jsonOrderDataPages addObjectsFromArray:orderApiData.result];
                }
            }
            if (block) {
                block(successWrite, self.jsonOrderDataPages, nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"OrderDataAPI.m - OrderData Response Failure For %d with error %@", pageNo,error.localizedDescription);
            if (block) {
                [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"OrderData call failure for pageNo %d with error %@", pageNo, error.localizedDescription]];
                block(NO, self.jsonOrderDataPages, error);
            }
        }];
    }
}
*/
- (BOOL) downloadedAllPages:(int) finalI {
    BOOL downloadedAllPages = NO;
    if ([self.jsonOrderDataPages count] >= self.totalNumberOfData) {
        [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"OrderData Download Complete"]];
        downloadedAllPages = YES;
        [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Saving OrderData to DB"]];
        NSLog(@"AllPagesDownloaded");
        [self insertRowDataForDB];
        [[User sharedUser] addTrackingLog:[NSString stringWithFormat:@"Saving OrderData to DB Complete"]];
        SyncManager *syncManager = [[SyncManager alloc] init];
        NSLog(@"sendLogsToBackend");
        [syncManager sendLogsToBackend];
    }
    return downloadedAllPages;
}

#pragma mark - SQL Methods

+ (NSString *) getTableCreateStatmentForOrderData {
    NSString *sql =[NSString stringWithFormat:@"CREATE TABLE %@", TBL_ORDERDATA];
    sql = [sql stringByAppendingString:@" ("];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_ID, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_DCNAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_RECEIVED_DATETIME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_DELIVERY_EXPECTED_DATETIME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_PO_NUMBER, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_GRN, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_PO_LINE_NUMBER, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_ITEM_NUMBER, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_ITEM_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_VENDOR_CODE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_VENDOR_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_QUANTITY_OF_CASES, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_PO_LINE_NUMBER_VALUE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_CARRIER_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_PROGRAM_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_FLAGGED_PRODUCT, SQLITE_TYPE_INTEGER];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_FLAGGED_MESSAGES, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_FLAGGED_MESSAGES_ALL, SQLITE_TYPE_BLOB];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_MESSAGE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_SCORE, SQLITE_TYPE_TEXT];
   // sql = [sql stringByAppendingFormat:@"%@ %@",COL_ORDER_LOAD_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_LOAD_ID, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@,",COL_ORDER_CUSTOMER_CODE, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingFormat:@"%@ %@",COL_ORDER_CUSTOMER_NAME, SQLITE_TYPE_TEXT];
    sql = [sql stringByAppendingString:@")"];
    return sql;
}


- (void) insertRowDataForDB {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    [database open];
    //NSLog(@"Inserting Pages in DB %d", [self.jsonOrderDataPages count]);
    for (int i=0; i < [self.jsonOrderDataPages count]; i++) {
        OrderData *orderData = [self.jsonOrderDataPages objectAtIndex:i];
        NSData *flagMsg = [NSKeyedArchiver archivedDataWithRootObject:orderData.FlaggedMessages];
        NSData *allFlagMsgs = [NSKeyedArchiver archivedDataWithRootObject:orderData.allFlaggedProductMessages];
        [database executeUpdate:@"insert into ORDER_DATA (ORDER_ID,ORDER_DC_NAME, ORDER_RECEIVED_DATETIME, ORDER_DELIVERY_EXPECTED_DATETIME, ORDER_PO_NUMBER,ORDER_GRN, ORDER_PO_LINE_NUMBER, ORDER_ITEM_NUMBER, ORDER_ITEM_NAME, ORDER_VENDOR_CODE, ORDER_VENDOR_NAME, ORDER_QUANTITY_OF_CASES, ORDER_PO_LINE_NUMBER_VALUE, ORDER_CARRIER_NAME, ORDER_PROGRAM_NAME, ORDER_FLAGGED_PRODUCT, ORDER_MESSAGE, ORDER_SCORE, ORDER_FLAGGED_MESSAGES,ORDER_FLAGGED_MESSAGES_ALL,ORDER_LOAD_ID,ORDER_CUSTOMER_CODE,ORDER_CUSTOMER_NAME) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [NSString stringWithFormat:@"%d", orderData.ID],orderData.DCName, orderData.ReceivedDateTime, orderData.ExpectedDeliveryDateTime, orderData.PONumber, orderData.grn, orderData.POLineNumber, orderData.ItemNumber, orderData.ItemName, orderData.VendorCode, orderData.VendorName,  orderData.QuantityOfCases, orderData.POLineNumberValue, orderData.CarrierName, orderData.ProgramName, [NSString stringWithFormat:@"%d", orderData.FlaggedProduct?1:0], orderData.Message, orderData.score, flagMsg,allFlagMsgs,orderData.loadId,orderData.CustomerCode,orderData.CustomerName];
    }
    [database close];
    [self removeDuplicateOrderDataEntries];
}

//when customer updates the count of cases for any order-data, then a new row is inserted - the old one needs to be removed and keep the latest
// 10/2016 updated to remove all rows other than MAX
-(void) removeDuplicateOrderDataEntries {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_ORDER_DATA];
    [database open];
    NSString* cleanUpQuery = [NSString stringWithFormat:@"select ORDER_PO_NUMBER,ORDER_GRN,ORDER_ITEM_NUMBER,ORDER_VENDOR_NAME, ORDER_DELIVERY_EXPECTED_DATETIME, MAX(ORDER_ID) as ORDER_ID, count(*) as cnt from ORDER_DATA group by ORDER_PO_NUMBER,ORDER_ITEM_NUMBER,ORDER_VENDOR_NAME, ORDER_DELIVERY_EXPECTED_DATETIME"];
    // trying to achive this by a single query
    /*cleanUpQuery = @"Delete from order_data where order_id not in (Select order_id from (ORDER_PO_NUMBER,ORDER_ITEM_NUMBER,ORDER_VENDOR_NAME, ORDER_DELIVERY_EXPECTED_DATETIME, MAX(ORDER_ID) as ORDER_ID, count(*) as cnt from ORDER_DATA group by ORDER_PO_NUMBER,ORDER_ITEM_NUMBER,ORDER_VENDOR_NAME, ORDER_DELIVERY_EXPECTED_DATETIME)";*/
    FMResultSet *resultsGroupRatings;
    resultsGroupRatings = [database executeQuery:cleanUpQuery];
    NSMutableArray* orderDataIdsToRemove = [[NSMutableArray alloc]init];
    while ([resultsGroupRatings next]) {
        NSError *err = nil;
        [orderDataIdsToRemove addObject:[resultsGroupRatings stringForColumn:COL_ORDER_ID]];
    }
    if([orderDataIdsToRemove count]>0){
        NSString *joinedComponents = [orderDataIdsToRemove componentsJoinedByString:@","];
        NSString *deleteQuery = [NSString stringWithFormat:@"Delete from ORDER_DATA where ORDER_ID NOT in (%@)",joinedComponents];
        //NSLog(@"joinedComponents length is %ld and value is: %@",[orderDataIdsToRemove count],joinedComponents);
        //NSLog(@"Delete Query is: %@",deleteQuery);
        [database executeUpdate:deleteQuery];
    }
    /*NSString* query = [NSString stringWithFormat:@"select count(*) as COUNT from ORDER_DATA"];
    FMResultSet *results;
    results = [database executeQuery:query];
    while ([results next]) {
        NSError *err = nil;
        NSString* res = [results stringForColumn:@"COUNT"];
        NSLog(@"count after delete is : %@",res);
    }*/
    [database close];
}

//- (NSString *) insertStatement:(OrderData *) orderData {
//    NSString *DCNameString = [NSString stringWithFormat:@"%@", orderData.DCName];
//    DCNameString = [DCNameString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSString *insertStatement = [NSString stringWithFormat:@"INSERT INTO %@", TBL_ORDERDATA];
//    insertStatement = [insertStatement stringByAppendingString:@" ("];
//    insertStatement = [insertStatement stringByAppendingFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@", COL_ORDER_PROGRAM_NAME];
//    insertStatement = [insertStatement stringByAppendingString:@") "];
//    insertStatement = [insertStatement stringByAppendingString:@"VALUES ("];
//    insertStatement = [insertStatement stringByAppendingFormat:@"'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@'",orderData.DCName, orderData.ReceivedDateTime, orderData.ExpectedDeliveryDateTime, orderData.PONumber, orderData.POLineNumber, orderData.ItemNumber, orderData.ItemName, orderData.VendorCode, orderData.VendorName,  orderData.QuantityOfCases, orderData.POLineNumberValue, orderData.CarrierName, orderData.ProgramName];
//    insertStatement = [insertStatement stringByAppendingString:@");"];
//    return insertStatement;
//}


@end
