//
//  CollobarativeInspection.h
//  Insights
//
//  Created by Vineet Pareek on 3/11/2015.
//  Copyright © 2015 Yottamark. All rights reserved.
//o

#import <Foundation/Foundation.h>
#import "DCBaseEntity.h"
#import "CollaborativeAPIListRequest.h"
#import "CollaborativeAPISaveRequest.h"
#import "Product.h"

@interface CollobarativeInspection : DCBaseEntity

//array of CollobarativeProduct object from backend
@property (nonatomic, strong) NSMutableArray* listOfProducts;
@property (nonatomic,strong) NSMutableDictionary* poStatusMap;
@property (nonatomic,strong) NSMutableDictionary* supplierStatusMap;
@property (nonatomic,strong) NSMutableDictionary* productStatusMap;
@property (nonatomic,strong) NSMutableDictionary* itemNumberAndProductIdMap;
@property (nonatomic,strong) NSMutableDictionary* poAndItemNumberMapFromOrderData;

-(void) getAllPOStatus:(CollaborativeAPIListRequest*)poNumbers
             withBlock:(void (^)(NSArray* productList, NSError *error))block;

-(void) updateCollaborativeInspection:(CollaborativeAPISaveRequest*)apiSaveRequest
                                     withBlock:(void (^)(BOOL success, NSError *error))block;

-(void) startInspectionForProduct:(int)productId inPO:(NSString*)poNumber withBlock:(void(^)(BOOL success))respond;
-(void) initCollabInspectionsForPO:(NSString*)poNumber withBlock:(void(^)(BOOL success))respond;
-(int)getStatusForProduct:(int)productId inPO:(NSString*)poNumber;
-(int)getStatusForSupplier:(NSString*) supplierName;
-(int)getStatusForPO:(NSString*)poNumber;
-(NSString*)getMessageForProduct:(Product*)product;

-(NSMutableSet*)getListOfUsersForSupplier:(NSString*)supplier;
-(NSMutableSet*)getListOfUsersForPO:(NSString*)po;
-(NSMutableSet*)getListOfUsersForProduct:(int)productId inPO:(NSString*)poNumber;

//-(void) finishProductsForPO:(CollaborativeAPISaveRequest*)product withBlock:(void (^)(BOOL success, NSError *error))block;

//-(NSMutableDictionary*) getPOStatusMap;
//-(NSMutableDictionary*) getSupplierStatusMap;
//-(NSMutableDictionary*) getProductStatusMap;

+(void) enableCollaborativeInspections;
+(void) disableCollaborativeInspections;
+(BOOL) isCollaborativeInspectionsEnabled;


@end
