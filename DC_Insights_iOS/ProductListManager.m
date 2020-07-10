//
//  DCInspection.m
//  Insights
//
//  Created by Vineet Pareek on 15/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import "ProductListManager.h"
#import "Inspection.h"
#import "ProductListItem.h"
#import "ProductListItemGroup.h"


@implementation ProductListManager

//TODO optimize for time
//add split product groups
// Other/Other option
-(NSMutableArray*)getProductsList:(BOOL)allProducts
{
    //get list of products from DB for store/program
    NSMutableArray* productGroups = [[NSMutableArray alloc]init];
    productGroups = [self getProductGroups]; // 2nd longest
    [Inspection sharedInspection].productGroups = [self getProductGroups];
    NSMutableArray* savedAuditsList = [[NSMutableArray alloc]init];
    NSSet *set = [[NSSet alloc]init];
    //order-data
    if(!allProducts){
        if([[Inspection sharedInspection]checkForOrderData] ||
           [[Inspection sharedInspection] isNoneSelectedForPOSupplier]) { //or NONE
            //flatten out the groups //filter based on PO/Supplier
            NSSet *set;
            NSString *poNumber = [Inspection sharedInspection].poNumberGlobal;
            if((![poNumber  isEqual: @""]) && (poNumber != nil)){
                set = [OrderData getItemNumbersForPONumberSelected];
            }else{
                set  = [OrderData getItemNumbersForGRNSelected];
            }
            productGroups = [self filteredProductGroups:set withProductGroups:productGroups];
            productGroups = [self flattenProductGroups:productGroups];
        }
    }
    
    //filter for containers
    productGroups = [[[User sharedUser].currentStore filterProductsBasedOnContainers:productGroups] mutableCopy];
    //NSLog(@"DCInspection - productGroups count is: %ld",[productGroups count]);
    if ([[[Inspection sharedInspection] getAllSavedAuditsForInspection]  count] > 0)  {
        [Inspection sharedInspection].productGroups = productGroups;
        //get completed audits
        savedAuditsList = [[[Inspection sharedInspection] getAllSavedAndFakeAuditsForInspection]mutableCopy]; //takes longest
    } else {
        savedAuditsList = [[NSMutableArray alloc] init];
    }
    
    //add completed samples
    //[self recalculateSavedAuditsWithDatabase:nil forSavedAudits:(NSMutableArray*)savedAuditsList];
    [self populateSavedAuditsWithSummaryInfo:savedAuditsList withDatabase:nil]; //
    
    //add split-groups
    //productGroups = [self addSplitProductGroups:productGroups withSavedAudits:savedAuditsList];
    
    [Inspection sharedInspection].productGroups = productGroups;
    
    //go through product groups and create the List
    NSMutableArray *productListArray = [[NSMutableArray alloc]init];
    int count = 0;
    for (int i=0; i < [productGroups count]; i++) {
        if ([[productGroups objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *programGroup = [productGroups objectAtIndex:i];
            ProductListItemGroup *listItemGroup = [[ProductListItemGroup alloc]init];
            listItemGroup.name = programGroup.name;
            listItemGroup.productListItemArray = [[NSMutableArray alloc]init];
            
            NSArray *products = programGroup.products;
            for(Product *product in products){
                ProductListItem *listItem = [self getProductListItemForProduct:product
                                                           withSavedAuditsList:savedAuditsList
                                                               withItemNumbers:set];
                [listItemGroup.productListItemArray addObject:listItem];
                count++;
            }
            [productListArray addObject:listItemGroup]; //add group
            //add to productListItemParent
        } else if ([[productGroups objectAtIndex:i] isKindOfClass:[Product class]]){
            Product *product = [productGroups objectAtIndex:i];
            ProductListItem *listItem = [self getProductListItemForProduct:product
                                                       withSavedAuditsList:savedAuditsList
                                                           withItemNumbers:set];
            [productListArray addObject:listItem]; //add product
            count++;
        }
    }
    NSLog(@"DCInspection - Final productListArray count is: %ld with totalCount of Products is %d",[productListArray count], count);
    return productListArray;
    
}
/*
-(NSArray*)getFlattenedProductsList:(BOOL)allProducts {
    NSArray* filteredProductsAndGroups = [self getProductsList:allProducts];
    NSMutableArray* flatProductsList = [[NSMutableArray alloc]init];
    for(id product in filteredProductsAndGroups){
        if ([product isKindOfClass:[ProductListItemGroup class]]) {
            ProductListItemGroup *productListItemGroup = product;
            NSArray* productArray = productListItemGroup.productListItemArray;
            for(ProductListItem *item in productArray){
                [flatProductsList addObject:item];
            }
        } else {
            ProductListItem *productListItem = product;
            [flatProductsList addObject:productListItem];
        }
    }
    return flatProductsList;
}

-(NSArray*)getSkusForProductsList:(BOOL)allProducts {
    NSArray *productsFilteredByOrderData = [self getFlattenedProductsList:YES];
    NSMutableArray* allSkus = [[NSMutableArray alloc]init];
    for(ProductListItem* product in productsFilteredByOrderData){
        NSString* sku =[product.product.skus objectAtIndex:0];
        //NSLog(@"SKU is: %@",[product.product.skus objectAtIndex:0]);
        if(sku && ![sku isEqualToString:@""])
            [allSkus addObject:sku];
    }
    return [allSkus copy];
}
*/
-(int)countProductsIn:(NSArray*)productGroups {
    NSMutableArray *productListArray = [[NSMutableArray alloc]init];
    int count = 0;
    for (int i=0; i < [productGroups count]; i++) {
        if ([[productGroups objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *programGroup = [productGroups objectAtIndex:i];
            NSArray *products = programGroup.products;
            for(Product *product in products){
                count++;
            }
            //add to productListItemParent
        } else if ([[productGroups objectAtIndex:i] isKindOfClass:[Product class]]){
            Product *product = [productGroups objectAtIndex:i];
            count++;
        }
    }
    return count;
}

-(ProductListItem*)getProductListItemForProduct:(Product*)product
                            withSavedAuditsList:(NSMutableArray*)savedAuditsList
                                withItemNumbers:(NSSet*)itemNumberSet
{
    //order-data
    NSString *sku = product.selectedSku;
    if (!sku || [sku isEqualToString:@""]) {
        for (NSString *skuLocal in [itemNumberSet allObjects]) {
            for (NSString *skuLocal2 in product.skus) {
                if ([skuLocal2 isEqualToString:skuLocal]) {
                    sku = skuLocal2;
                    break;
                }
            }
        }
    }
    if (!sku || [sku isEqualToString:@""]) {
        sku = [product.skus lastObject];
    }
    NSString *PONumber = [Inspection sharedInspection].poNumberGlobal;
    NSString *GRN = [Inspection sharedInspection].grnGlobal;
    //slow code - queries DB for every iteration
    OrderData *orderData;
    if((![PONumber  isEqual: @""]) && (PONumber != nil))
        orderData = [OrderData getOrderDataWithPO:PONumber
                                    withItemNumber:sku
                                          withTime:[[Inspection sharedInspection] dateTimeForOrderData]];
    else
        orderData = [OrderData getOrderDataWithGRN:GRN
        withItemNumber:sku
              withTime:[[Inspection sharedInspection] dateTimeForOrderData]];
        
    
    

    
    //SavedAudit
    SavedAudit *savedAuditForProduct = [[SavedAudit alloc]init];
    for (SavedAudit *savedAudit in savedAuditsList) {
        if (savedAudit.productGroupId == product.group_id) {
            if (savedAudit.productId == product.product_id) {
                savedAuditForProduct = savedAudit;
            }
        }
    }
    
    //add to productListItemParent
    ProductListItem *listItem = [[ProductListItem alloc]init];
    listItem.product  = product;
    listItem.orderData = orderData;
    savedAuditForProduct.score = orderData.score;
    listItem.savedAudit = savedAuditForProduct;
    //listItem.collaborativeInspectionStatus = collaborativeStatus;
    //listItem.collaborativeInspectionMessage = collaborativeMessage;
    
    return listItem;

}

//for OrderData
-(NSMutableArray*)flattenProductGroups:(NSMutableArray*)productGroups
{
    NSMutableArray* flattenedProductGroups = [[NSMutableArray alloc]init];
    for (int i=0; i < [productGroups count]; i++) {
        if ([[productGroups objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup* programGroup =[productGroups objectAtIndex:i];
            NSArray *products = programGroup.products;
            for(Product *product in products){
                [flattenedProductGroups addObject:product];
            }
            //add to productListItemParent
        } else if ([[productGroups objectAtIndex:i] isKindOfClass:[Product class]]){
            Product *product = [productGroups objectAtIndex:i];
            [flattenedProductGroups addObject:product];
        }
    }
    return flattenedProductGroups;
}

-(NSMutableArray*)populateCollaborativeInspectionDataInProductList:(NSMutableArray*)productList
{
    for(ProductListItem *item in productList){
        //Collaborative
        int collaborativeStatus = STATUS_NOT_STARTED;
        NSString* collaborativeMessage = @"";
        CollobarativeInspection* collobarativeInsp = [Inspection sharedInspection].collobarativeInspection;
        //not for collaboartive inspections
        if([item isKindOfClass:[ProductListItemGroup class]])
            continue;
            
        if(collobarativeInsp && [CollobarativeInspection isCollaborativeInspectionsEnabled] && [[Inspection sharedInspection]checkForOrderData]){
            NSString *po = [Inspection sharedInspection].poNumberGlobal;
            
            collaborativeStatus = (int)[collobarativeInsp getStatusForProduct:item.product.product_id inPO:po];
            collaborativeMessage = [collobarativeInsp getMessageForProduct:[item.product getCopy]];
        }
        item.collaborativeInspectionMessage = collaborativeMessage;
        item.collaborativeInspectionStatus = collaborativeStatus;
    }
    return productList;
}

-(NSMutableArray*)getProductGroups
{
    NSMutableArray* productsList = [[NSMutableArray alloc]init];
    productsList = [[User sharedUser].currentStore.productGroups mutableCopy];
    
    if([productsList count]==0)
        productsList = [[[User sharedUser].currentStore getProductGroups] mutableCopy];
    
    return [self sortProductGroupByName:productsList];
}

- (NSMutableArray*) sortProductGroupByName:(NSArray*)productGroups {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sort];
    return [[productGroups sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

- (NSMutableArray *) filteredProductGroups: (NSSet *) itemNumbers withProductGroups:(NSMutableArray*)productGroups {
    if ([itemNumbers count] == 0) {
        return productGroups;
    }
    NSArray *itemNumbersArray = [itemNumbers allObjects];
    NSArray *productGroupsArrayLocal = [productGroups mutableCopy];
    NSMutableArray *newProductGroupsSet = [NSMutableArray array];
    for (int i=0; i < [productGroupsArrayLocal count]; i++) {
        if ([[productGroupsArrayLocal objectAtIndex:i] isKindOfClass:[ProgramGroup class]]) {
            ProgramGroup *prg = [[productGroupsArrayLocal objectAtIndex:i] mutableCopy];
            NSArray *products = prg.products;
            NSMutableArray *newProductsArray = [NSMutableArray array];
            for (Product *product in products) {
                if(!product.skus)
                    continue;
                NSString * result = [[product.skus valueForKey:@"description"] componentsJoinedByString:@""];
                for (NSString *sku in product.skus) {
                    for (int j=0; j < [itemNumbersArray count]; j++) {
                        if ([sku isEqualToString:[itemNumbersArray objectAtIndex:j]]) {
                            product.selectedSku = sku;
                            [newProductsArray addObject:product];
                        }
                    }
                }
            }
            if ([newProductsArray count] > 0) {
                prg.products = newProductsArray;
                [newProductGroupsSet addObject:prg];
            }
        } else {
            Product *product = [[productGroupsArrayLocal objectAtIndex:i] mutableCopy];
            for (NSString *sku in product.skus) {
                for (int j=0; j < [itemNumbersArray count]; j++) {
                    if ([sku isEqualToString:[itemNumbersArray objectAtIndex:j]]) {
                        product.selectedSku = sku;
                        [newProductGroupsSet addObject:product];
                    }
                }
            }
        }
    }
    NSArray *newProductGroupsArray;
    newProductGroupsArray = [newProductGroupsSet copy];
    if ([newProductGroupsArray count] == 0) {
        if (!FILTER_PRODUCTS_CONTAINERS) {
            newProductGroupsArray = productGroupsArrayLocal;
        }
    }
    return newProductGroupsArray;
}

- (NSMutableArray*) populateSavedAuditsWithSummaryInfo:(NSMutableArray*)savedAuditsList withDatabase:(FMDatabase*)databaseLocal{
    NSMutableArray *savedAuditsLocal = [[NSMutableArray alloc] init];
    FMResultSet *resultsGroupRatingsForSavedAudit;
    FMDatabase *databaseGroupRatings;
    if (!databaseLocal || ![databaseLocal goodConnection]) {
        databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_APP_DATA];
        [databaseGroupRatings open];
    } else {
        databaseGroupRatings = databaseLocal;
    }
    for (SavedAudit *savedAudit in savedAuditsList) {
        NSString *queryStringForSavedAudit = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%d' AND %@='%d' AND %@='%@' AND %@='%@'", TBL_SAVED_SUMMARY, COL_PRODUCT_ID, savedAudit.productId, COL_PRODUCT_GROUP_ID, savedAudit.productGroupId, COL_AUDIT_MASTER_ID, [Inspection sharedInspection].auditMasterId,COL_SPLIT_GROUP_ID,savedAudit.splitGroupId];
        resultsGroupRatingsForSavedAudit = [databaseGroupRatings executeQuery:queryStringForSavedAudit];
        while ([resultsGroupRatingsForSavedAudit next]) {
            AuditApiSummary *summary = [[AuditApiSummary alloc] initWithString:[resultsGroupRatingsForSavedAudit stringForColumn:COL_SUMMARY] error:nil];
            savedAudit.inspectionStatus = summary.inspectionStatus;
            NSString *userEnteredInspectionSamples = [resultsGroupRatingsForSavedAudit stringForColumn:COL_USERENTERED_SAMPLES];
            if (userEnteredInspectionSamples && ![userEnteredInspectionSamples isEqualToString:@""]) {
                savedAudit.userEnteredAuditsCount = [userEnteredInspectionSamples integerValue];
            }
            //savedAudit.countOfCases = [[resultsGroupRatingsForSavedAudit stringForColumn:COL_COUNT_OF_CASES] integerValue];
        }
        [savedAuditsLocal addObject:savedAudit];
    }
    if (!databaseLocal) {
        [databaseGroupRatings close];
    }
    return [savedAuditsLocal copy];
}


//add split products to the ProductGroups
-(NSMutableArray*)addSplitProductGroups:(NSMutableArray*)productGroups withSavedAudits:(NSArray*)productAudits{
    
    if([productAudits count]<=0)
        return productGroups;
    //create a map of productId and array of SavedAudits (with different split groups)
    NSMutableDictionary *productIdAndSavedAuditsDictionary = [[NSMutableDictionary alloc]init];
    for(SavedAudit *savedAudit in productAudits){
        NSMutableArray* savedAuditsForASplitGroup = [[NSMutableArray alloc]init];
        if([productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:savedAudit.productId]]){
            savedAuditsForASplitGroup =[productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:savedAudit.productId]];
        }
        [savedAuditsForASplitGroup addObject:savedAudit];
        [productIdAndSavedAuditsDictionary setObject:savedAuditsForASplitGroup forKey:[NSNumber numberWithInt:savedAudit.productId]];
    }
    NSMutableArray* mutableProductGroups = [[NSMutableArray alloc]init];
    //mutableProductGroups = [self.productGroups mutableCopy];
    
    if ([[productGroups objectAtIndex:0] isKindOfClass:[ProgramGroup class]]){
        return productGroups;
    }
    for(Product *product in productGroups){
        if([product isKindOfClass:[ProgramGroup class]])
            continue;
        
        if([productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:(int)product.product_id]]){
            NSMutableArray* savedAuditsForASplitGroup =[productIdAndSavedAuditsDictionary objectForKey:[NSNumber numberWithInt:(int)product.product_id]];
            for(int i=0; i<[savedAuditsForASplitGroup count]; i++){
                Product *productCopy = [product getCopy];
                productCopy.savedAudit = savedAuditsForASplitGroup[i];
                [mutableProductGroups addObject:productCopy];
            }
        }else{
            Product *productCopy = [product getCopy];
            productCopy.savedAudit = [[SavedAudit alloc]init];
            [mutableProductGroups addObject:productCopy];
        }
    }
    return mutableProductGroups;
    
}





@end
