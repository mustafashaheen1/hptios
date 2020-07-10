//
//  CollobarativeInspection.m
//  Insights


#import "CollaborativeInspection.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLConnectionOperation.h"
#import "OrderData.h"
#import "Inspection.h"
#import "JSONHTTPClient.h"
#import "SyncManager.h"
#import "CollaborativeAPIResponse.h"
#import "CollabSyncManager.h"

@interface CollobarativeInspection()
//private variables
@property (nonatomic,strong) NSMutableDictionary* poAndProductsStatusMap;
@property (nonatomic,strong) NSMutableArray* listOfCollaborativeProducts;
@property (nonatomic,strong) NSMutableDictionary* supplierPOMap;
@end

@implementation CollobarativeInspection

@synthesize listOfProducts;

-(void) getAllPOStatus:(CollaborativeAPIListRequest*)apiRequest
             withBlock:(void (^)(NSArray* productList, NSError *error))block{
    apiRequest.auth_token =[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    apiRequest.device_id =[DeviceManager getDeviceID];
    CollabSyncManager *collabSyncManager = [[CollabSyncManager alloc]init];
    [collabSyncManager getPOStatus:apiRequest withBlock:^(NSArray *productList, NSError *error) {
        NSLog(@"Collaborative /api/list Local+Remote Response %@", productList);
        if(!productList || [productList count]<=0) {
            block(nil, error);
        }
        else{
            NSMutableArray* array = [productList mutableCopy];
            self.listOfProducts = array;
            [self populateMaps];
            if (block) {
                block(array, nil);
            }
        }
    }];
}

-(NSArray*)update:(NSArray*)response
{
    NSMutableArray* models = [[NSMutableArray alloc]init];
    //NSLog(@"Models are: %@",models);
    
    for(NSMutableDictionary* object in response){
        //NSString *po = product objectForKey:@"po";
        //[object setValue:0 forKey:@"user_id"];
        NSError *err = nil;
        CollaborativeAPIResponse* product = [[CollaborativeAPIResponse alloc]initWithDictionary:object error:&err];
        
        if(product.product_id==0 || ![self isProductBelongsToPO:product.po withProductId:product.product_id])
            //or the PO-product do not match
            continue;
        
        [models addObject:product];
    }
    return [models copy];
}

// populate PO, Supplier and Product maps for quick search
-(void) populateMaps{
    
    //dictionary of PONumber and Status
    NSMutableDictionary* poStatusMap = [[NSMutableDictionary alloc]init];
    //dictionary of Product and Status
    NSMutableDictionary* productStatusMap = [[NSMutableDictionary alloc]init];
    //dictionary of Supplier and Status
    NSMutableDictionary* supplierStatusMap = [[NSMutableDictionary alloc]init];
    
    //TODO: move poSupplierMap init to inspection class - since this needs to be done only once
    
    //create a map of PO and Supplier from OrderData
    //create a map of PO and count of product
    NSArray *orderDataArray =  [[Inspection sharedInspection] getOrderData];
    self.itemNumberAndProductIdMap = [self getProductIdAndItemNumberMap];
    //NSMutableDictionary* poSupplierMap = [[NSMutableDictionary alloc]init]; //Map - <PO, Supplier>
    NSMutableDictionary* supplierPOMap = [[NSMutableDictionary alloc]init]; // Map - <Supplier, List<PO>>
    self.poAndItemNumberMapFromOrderData =  [[NSMutableDictionary alloc]init];
    for(OrderData *order in orderDataArray){
        NSMutableArray* productIds = [[NSMutableArray alloc]init];
        productIds = [self.poAndItemNumberMapFromOrderData objectForKey:order.PONumber];
        if(!productIds)
            productIds = [[NSMutableArray alloc]init];
        [productIds addObject:order.ItemNumber];
        [self.poAndItemNumberMapFromOrderData setObject:productIds forKey:order.PONumber];
            
        
        //build supplier and PO map - all the POs for any supplier
        NSMutableArray *listOfPOForSupplier = [supplierPOMap objectForKey:order.VendorName];
        if(!listOfPOForSupplier){
            listOfPOForSupplier = [[NSMutableArray alloc]init];
        }
        [listOfPOForSupplier addObject:order.PONumber];
        [supplierPOMap setObject:listOfPOForSupplier forKey:order.VendorName];
    }
    self.supplierPOMap = supplierPOMap;
    
    //map of PO and the corresponding products received from the API call
    //dictionary is productId<->status - since status is per product - per PO
    NSMutableDictionary <NSString *, NSMutableDictionary *> *poAndProductsMap = [[NSMutableDictionary alloc]init];
    self.listOfCollaborativeProducts = [[NSMutableArray alloc]init];
    for(CollaborativeAPIResponse* product in self.listOfProducts){
        /*NSError *err = nil;
        CollaborativeAPIResponse* product = [[CollaborativeAPIResponse alloc]initWithDictionary:object error:&err];*/
        
        if(product.product_id==0 || ![self isProductBelongsToPO:product.po withProductId:product.product_id])
            //or the PO-product do not match
            continue;
        
        [self.listOfCollaborativeProducts addObject:product];
      
        NSMutableDictionary* productsForPO = [[NSMutableDictionary alloc]init];
        if([poAndProductsMap objectForKey:product.po])
        productsForPO = [poAndProductsMap objectForKey:product.po];
        
        [productsForPO setObject:[NSNumber numberWithInt:product.status] forKey:[NSNumber numberWithInt:product.product_id]];
        [poAndProductsMap setObject:productsForPO forKey:product.po];
        
    }
    self.poAndProductsStatusMap = poAndProductsMap;
    
    //populate poSupplierMap
    
    NSArray* allPOFromAPIResponse = [[NSMutableArray alloc]init];
    allPOFromAPIResponse = [poAndProductsMap allKeys];
    
    for(NSString* po in allPOFromAPIResponse){
        NSMutableArray* itemNumbersForPO = [self.poAndItemNumberMapFromOrderData objectForKey:po];
        int countOfProductsFromOrderData =(int)[itemNumbersForPO count];
        NSMutableDictionary* productAndStatusMap = [poAndProductsMap objectForKey:po];
        int countOfProductsFromAPIResponse = (int)[[productAndStatusMap allKeys]count];
        int calculatedStatus = STATUS_NOT_STARTED;
      
        int countOfFinishedProducts = 0;
        //refactor
        for(NSNumber *productId in [productAndStatusMap allKeys]){
            long prodStatus =[[productAndStatusMap objectForKey:productId] integerValue];
            //if any 1 product is in started status then the entire PO is started
            if(prodStatus== STATUS_STARTED){
                calculatedStatus = STATUS_STARTED;
                break;
            }
            if(prodStatus == STATUS_FINSIHED)
                countOfFinishedProducts++;
            //if all products from orderdata are finished
            if(countOfFinishedProducts == countOfProductsFromOrderData)
                calculatedStatus = STATUS_FINSIHED;
            //if any or some products are in finished the PO status is started
            else if(countOfFinishedProducts>0)
                calculatedStatus = STATUS_STARTED;
            
        }
        [poStatusMap setObject:[NSNumber numberWithInt:calculatedStatus] forKey:po];
        //NSString* supplier = [poSupplierMap objectForKey:po];
        //[supplierStatusMap setObject:[NSNumber numberWithInt:calculatedStatus] forKey:supplier];
    }
    
    //go through all POs and set the supplier status
    NSArray *allSuppliers = [supplierPOMap allKeys];
    for(NSString* supplier in allSuppliers){
        NSMutableArray* poNumbers = [supplierPOMap objectForKey:supplier];
        int supplierStatus = STATUS_NOT_STARTED;
        int count = (int)[poNumbers count];
        int countOfFinishedPO = 0;
        for(NSString* po in poNumbers){
         int poStatus = [[poStatusMap objectForKey:po]intValue];
            //if any 1 product is in started status then the entire PO is started
            if(poStatus== STATUS_STARTED){
                supplierStatus = STATUS_STARTED;
                break;
            }
            if(poStatus == STATUS_FINSIHED)
                countOfFinishedPO++;
            //if all products from orderdata are finished
            if(countOfFinishedPO == count)
                supplierStatus = STATUS_FINSIHED;
            //if any or some products are in finished the PO status is started
            else if(countOfFinishedPO>0)
                supplierStatus = STATUS_STARTED;
        }
        [supplierStatusMap setObject:[NSNumber numberWithInt:supplierStatus] forKey:supplier];
    }
    
    self.poStatusMap = poStatusMap;
    self.supplierStatusMap = supplierStatusMap;
    self.productStatusMap = productStatusMap;
    
}

-(BOOL)isProductBelongsToPO:(NSString*)poNumber withProductId:(int)productId
{
    //find the itemNumber for ProductId
    NSString* itemNumber = [self.itemNumberAndProductIdMap objectForKey:[NSNumber numberWithInt:(int)productId]];
    NSArray* itemNumbersInPO = [self.poAndItemNumberMapFromOrderData objectForKey:poNumber];
    //check if PO and itemNumber match
    if(itemNumber && itemNumbersInPO){
        if([itemNumbersInPO containsObject:itemNumber])
            return YES;
    }
    return NO;

}

-(NSMutableDictionary*)getProductIdAndItemNumberMap
{
    NSMutableDictionary* mapOfProductAndItemNumber = [[NSMutableDictionary alloc]init];
    NSArray* groupsArray = [Inspection sharedInspection].productGroups;
    if(!groupsArray || [groupsArray count]==0)
        groupsArray = [User sharedUser].currentStore.productGroups;
    for (int i = 0; i < [groupsArray count]; i++) {
        if ([[groupsArray objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *prg = [groupsArray objectAtIndex:i];
            NSArray *products = prg.products;
            for (Product *product in products) {
                if(product.skus && [product.skus count]>0)
                [mapOfProductAndItemNumber setObject:product.skus[0] forKey:[NSNumber numberWithInt:(int)product.product_id]];
            }
        } else {
            Product *product = [groupsArray objectAtIndex:i];
            if(product.skus && [product.skus count]>0)
            [mapOfProductAndItemNumber setObject:product.skus[0] forKey:[NSNumber numberWithInt:(int)product.product_id]];
        }
    }
    return mapOfProductAndItemNumber;
}

-(NSMutableSet*)getListOfUsersForSupplier:(NSString*)supplier{
    NSMutableArray* listOfPOForSupplier = [self.supplierPOMap objectForKey:supplier];
    NSMutableSet *userList = [[NSMutableSet alloc]init];
    for(NSString* po in listOfPOForSupplier){
        NSMutableSet* set =[self getListOfUsersForPO:po];
        NSArray *array = [set allObjects];
        [userList addObjectsFromArray:array];
    }
    return userList;
}

-(NSMutableSet*)getListOfUsersForPO:(NSString*)po{
    //NSMutableDictionary* productStatusMap = [self.poAndProductsStatusMap objectForKey:po];
    //NSMutableArray* listOfProductsForPO = [productStatusMap allKeys];
    NSMutableSet *userList = [[NSMutableSet alloc]init];
    for(CollaborativeAPIResponse* product in self.listOfCollaborativeProducts){
        if([product.po isEqualToString:po])
            [userList addObject:product.user_id];
    }
    return userList;
}

-(NSMutableSet*)getListOfUsersForProduct:(int)productId inPO:(NSString*)poNumber{
    
    NSMutableSet *userList = [[NSMutableSet alloc]init];
    
    for(CollaborativeAPIResponse* product in self.listOfCollaborativeProducts){
       if(product.product_id == productId && [product.po isEqualToString:poNumber])
           [userList addObject:product.user_id];
    }
    return userList;
}

-(int)getStatusForProduct:(int)productId inPO:(NSString*)poNumber {
    long status = STATUS_NOT_STARTED;
    if(self.poAndProductsStatusMap){
        NSMutableDictionary *productStatusMap = [self.poAndProductsStatusMap objectForKey:poNumber];
        status = [[productStatusMap objectForKey:[NSNumber numberWithInt:productId]] integerValue];
    }
    return (int)status;
}

-(int)getStatusForSupplier:(NSString*) supplierName {
    long status = STATUS_NOT_STARTED;
    if(self.supplierStatusMap){
        status = [[self.supplierStatusMap objectForKey:supplierName] integerValue];
    }
    return (int)status;
}

-(int)getStatusForPO:(NSString*)poNumber {
    long status = STATUS_NOT_STARTED;
    if(self.poStatusMap){
        status = [[self.supplierStatusMap objectForKey:poNumber] integerValue];
    }
    return (int)status;
}

-(NSString*)getMessageForProduct:(Product*)product
{
    NSString* message = @"";
    int collaborativeStatus = (int)[self getStatusForProduct:product.product_id inPO:[Inspection sharedInspection].poNumberGlobal];
    NSMutableSet* listOfUsersSet = [self getListOfUsersForProduct:product.product_id inPO:[Inspection sharedInspection].poNumberGlobal];
    NSArray *listOfUsersArray = [listOfUsersSet allObjects];
    NSString *listOfUsers = [listOfUsersArray componentsJoinedByString:@"\n"];
    if(collaborativeStatus == STATUS_STARTED)
        message = [NSString stringWithFormat:@"Inspections for \n%@\n have been started by %@",product.name,listOfUsers];
    if(collaborativeStatus == STATUS_FINSIHED)
        message = [NSString stringWithFormat:@"Inspections for \n%@\n have been finished by %@",product.name,listOfUsers];
    return message;
}


-(void) startInspectionForProduct:(int)productId inPO:(NSString*)poNumber withBlock:(void(^)(BOOL success))respond{
    if(!self.poAndProductsStatusMap){
        //need to init collab insp for the current PO
        [self initCollabInspectionsForPO:poNumber withBlock:^(BOOL success) {
            
            CollaborativeAPISaveRequest *apiSaveRequest = [[CollaborativeAPISaveRequest alloc]init];
            apiSaveRequest.store_id = (int)[User sharedUser].currentStore.storeID;
            [apiSaveRequest.product_ids addObject:[NSNumber numberWithInt:productId]];
            apiSaveRequest.po = [Inspection sharedInspection].poNumberGlobal;
            apiSaveRequest.status = STATUS_STARTED;
            if(![self.productStatusMap objectForKey:[NSNumber numberWithInt:productId]])
                [self updateCollaborativeInspection:apiSaveRequest withBlock:^(BOOL success, NSError *error) {
                    respond(success);
                }];
            else
                respond(YES);
        }];
    }else{
        
        CollaborativeAPISaveRequest *apiSaveRequest = [[CollaborativeAPISaveRequest alloc]init];
        apiSaveRequest.store_id = (int)[User sharedUser].currentStore.storeID;
        [apiSaveRequest.product_ids addObject:[NSNumber numberWithInt:productId]];
        apiSaveRequest.po = [Inspection sharedInspection].poNumberGlobal;
        apiSaveRequest.status = STATUS_STARTED;
        if(![self.productStatusMap objectForKey:[NSNumber numberWithInt:productId]])
            [self updateCollaborativeInspection:apiSaveRequest withBlock:^(BOOL success, NSError *error) {
                respond(success);
            }];
        else
            respond(YES);
    }
}

//in the middle of inspection it is enough to get inspections for just the PO
-(void) initCollabInspectionsForPO:(NSString*)poNumber withBlock:(void(^)(BOOL success))respond{
    /*NSArray *allPONumberObjects =  [[Inspection sharedInspection] getOrderData];
    NSMutableSet *poNumbersMutableSet = [NSMutableSet set];
    for (OrderData *orderData in allPONumberObjects) {
        [poNumbersMutableSet addObject:orderData.PONumber];
    }
    NSArray* poNumbers = [poNumbersMutableSet allObjects];*/
    
    NSArray* poNumbers = [NSArray arrayWithObjects:poNumber,nil];
    
    CollaborativeAPIListRequest *apiRequest = [[CollaborativeAPIListRequest alloc]init];
    apiRequest.po_numbers = [poNumbers mutableCopy];
    apiRequest.program_id = 0;
    apiRequest.store_id = (int)[User sharedUser].currentStore.storeID;
    
    [self getAllPOStatus:apiRequest withBlock:^(NSArray *productList, NSError *error) {
        respond(YES);
    }];
}

// update all the status maps based on any updated objects
-(void) updateMapsAfterSaveOperation:(NSMutableArray*)updatedObjectsArray {
    
    for(NSDictionary* productDict in updatedObjectsArray){
        NSError* err = nil;
        CollaborativeAPIResponse* product = [[CollaborativeAPIResponse alloc] initWithDictionary:productDict error:&err];
        
        //no need to update po and supplier map
        
        /*if(![self.poStatusMap objectForKey:product.po])
            [self.poStatusMap setObject:[NSNumber numberWithInt:product.status] forKey:product.po];*/
        
        if(![self.productStatusMap objectForKey:[NSNumber numberWithInt:product.product_id]])
            [self.productStatusMap setObject:[NSNumber numberWithInt:product.status] forKey:[NSNumber numberWithInt:product.product_id]];
        
        /*NSString* supplier = [self.poSupplierMap objectForKey:product.po];
        if(![self.supplierStatusMap objectForKey:supplier])
        [self.supplierStatusMap setObject:[NSNumber numberWithInt:product.status] forKey:supplier];*/
    }
   /*
    NSLog(@"---- updateMapsAfterSaveOperation called ---- ");
    NSLog(@"poStatusMap %@",self.poStatusMap);
    NSLog(@"supplierStatusMap %@",self.supplierStatusMap);
    NSLog(@"productStatusMap %@",self.productStatusMap);*/
}

-(void) updateCollaborativeInspection:(CollaborativeAPISaveRequest*)apiSaveRequest
                                    withBlock:(void (^)(BOOL success, NSError *error))block{
    //return response right away to unblock
    //TODO: refactor to remove the block call
    block(YES,nil);
    
    apiSaveRequest.auth_token =[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    apiSaveRequest.device_id =[DeviceManager getDeviceID];
    apiSaveRequest.user_id = [User sharedUser].email;
    NSDictionary *apiRequestDictionary = [apiSaveRequest toDictionary];
    NSLog(@"Collaborative /api/save: Saving Request to Local: %@", [apiSaveRequest toJSONString]);
    /*[[AFAppDotNetAPIClient sharedClient] postPath:collobarativeInspectionsSave parameters:apiRequestDictionary success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"updateCollaborativeInspection Response  %@", JSON);
            block(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO, error);
    }];*/
    NSMutableArray* productIds = apiSaveRequest.product_ids;
    int status = apiSaveRequest.status;
    NSString* po = apiSaveRequest.po;
    CollabSyncManager *manager = [[CollabSyncManager alloc]init];
    /*[manager saveStatus:status forProducts:productIds inPO:po withBlock:^(NSArray *productList, NSError *error) {
        if(error)
            block(NO,error);
        else
            block(YES,nil);
    }];*/
    //asynchronous call
    [manager saveStatus:status forProducts:productIds inPO:po withPostRequest:apiSaveRequest toURL:collobarativeInspectionsSave];
}

//TODO: move finish inspection to this class

/*
-(void) finishProductsForPO:(CollaborativeAPISaveRequest*)product
                  withBlock:(void (^)(BOOL success, NSError *error))block{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    //[parameters setObject:product.program_id forKey:@"program_id"];
    [parameters setObject:product.product_ids forKey:@"product_ids"];
    [parameters setObject:product.po forKey:@"po"];
    [parameters setObject:[NSNumber numberWithInteger:product.store_id] forKey:@"store_id"];
    [parameters setObject:[NSNumber numberWithInt:product.status] forKey:@"status"];
    
    //NSDictionary *apiRequestDictionary = [apiRequest toDictionary];
    [[AFAppDotNetAPIClient sharedClient] postPath:[NSString stringWithFormat:@"api/inspections?auth_token=%@&device_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"], [DeviceManager getDeviceID]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Request %@", JSON);
        NSMutableArray * array = [NSJSONSerialization JSONObjectWithData:JSON
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
        if ([array count]>0) {
            block(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO, error);
    }];
}
*/


+(void) enableCollaborativeInspections{
    [NSUserDefaultsManager saveBOOLToUserDefaults:YES withKey:colloborativeInspectionsEnabled];
}

+(void) disableCollaborativeInspections{
    [NSUserDefaultsManager saveBOOLToUserDefaults:NO withKey:colloborativeInspectionsEnabled];
}

+(BOOL) isCollaborativeInspectionsEnabled{
    if([[User sharedUser] checkForScanOut] || [[User sharedUser] checkForRetailInsights])
        return NO;
    
    return [NSUserDefaultsManager getBOOLFromUserDeafults:colloborativeInspectionsEnabled];
}


@end
