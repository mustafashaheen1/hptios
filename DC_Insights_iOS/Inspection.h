//
//  Inspection.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/3/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DCBaseEntity.h"
#import "Program.h"
#import "Container.h"
#import "CurrentAudit.h"
#import "CollaborativeInspection.h"
#import "NonOrderDataValues.h"

@interface Inspection : DCBaseEntity

@property (nonatomic, strong) NSString *auditMasterId;
@property (nonatomic, strong) NSString *currentAuditGroupId;
@property (nonatomic, strong) NSString *trackingKey;
@property (nonatomic, strong) Program *currentProgram;
@property (nonatomic, strong) NSString *poNumberGlobal;
@property (nonatomic, strong) NSString *grnGlobal;
@property (nonatomic, strong) NSString *containerId;

@property (nonatomic, strong) NSArray *allInspectionProducts;
@property (nonatomic, strong) NSArray *persistentRating;
@property (nonatomic, strong) CurrentAudit *currentAudit; // saves data from currentAudit product
@property (nonatomic, assign) BOOL isInspectionActive;
@property (nonatomic, strong) NSMutableArray *containerImages;
@property (nonatomic, strong) NSArray *productGroups;
@property (nonatomic, assign) BOOL removeBackFromProductSelect;
@property (nonatomic, strong) NSString *dateTimeForOrderData;
@property (nonatomic, strong) NSString *inspectionName;
@property (nonatomic, strong) NSArray *orderDataArray;
@property (nonatomic, assign) BOOL isOtherSelected;
@property (nonatomic, strong) CollobarativeInspection* collobarativeInspection;
@property (nonatomic, strong) NonOrderDataValues*  nonOrderDataInspectionValues;
//@property (nonatomic, strong) DCInspection* dcInspection;
@property (nonatomic, strong) NSString* currentSplitGroupId; //current split group Id
@property (nonatomic, strong) ApplyToAll* applyToAll;

//reference container data
@property (nonatomic, strong) Container *selectedContainer;

// saved container data
@property (nonatomic, strong) Container *savedContainer;

/*!
 *  Generate Container ratings JSON to save it to the database.
 *
 *  @return JSON string
 */
- (NSString *) generateContainerRatingsJson;
/*!
 *  Method to save Container Ratings to the database.
 */
- (void) saveContainerRatingsToDB;
- (NSArray *) getContainerFromDB;
/*!
 *  Initiate an inspection when the user enters all the valid container ratings.
 */
- (void)initInspection;
/*!
 *  Initiate an inspection with the audit master id.
 *
 *  @param auditMasterIdLocal Audit Master Id from the saved inspection.
 */
- (void) initInspectionWithMasterId: (NSString *) auditMasterIdLocal;
/*!
 *  Resume a saved inspection with the Audit Master Id
 *
 *  @param auditMasterIdLocal Audit Master Id from the saved inspection.
 */
- (void) resumeSavedInspection: (NSString *) auditMasterIdLocal;
/*!
 *  Set PONumber to the Inspection class.
 *
 *  @param poNumber PONumber selected by user.
 */
- (void) savePONumberToInspection: (NSString *) poNumber;
- (void) saveGRNToInspection: (NSString *) grn;
- (void) saveOtherToInspection: (BOOL) otherSelected;
- (void) saveContainerIdToInspection: (NSString *) containerId;

/*!
 *  This method checks for an Order data inspection.
 *
 *  @return Returns a boolean
 */
- (BOOL) checkForOrderData;
/*!
 *  This method checks if there is a date assigned to the Order data inspection.
 *
 *  @return Returns a boolean
 */
- (BOOL) checkForDateTime;
/*!
 *  This method generates all the saved and fake audits for the products for an Order data inspection.
 *
 *  @return Returns an array of Saved audits.
 */
- (NSArray *) getAllSavedAndFakeAuditsForInspection;
/*!
 *  This method filters all the product groups based on the item numbers and the sku numbers.
 *
 *  @param itemNumbers Item numbers array from the Order data table.
 *
 *  @return Returns an array of filtered Product groups including products.
 */
- (NSArray *) filteredProductGroups: (NSSet *) itemNumbers;
/*!
 *  This method returns all the product groups that are assigned for the store.
 */
- (NSArray *) getProductGroups;
- (NSArray *) getOrderData;
- (NSArray *) groupDefects: (NSArray *) defects;
/*!
 *  This method returns all the defects in groups as per the Defects grouping requirement. All the Defects are sorted based on the group names and also the severity names.
 *
 *  @param defects Defects array
 *
 *  @return Returns an array of all the Defect groups.
 */
- (void)groupDefects:(void (^)(NSArray *array))block withDefects:(NSArray *) defects;



/*!
 *  Gets all the saved audits for the inspection
 *
 *  @return Returns an array of Saved Audits.
 */
- (NSArray *) getAllSavedAuditsForInspection;
/*!
 *  Gets the product from the Insights DB using the product Id and product Group Id.
 *
 *  @param productId      ID for Product
 *  @param productGroupId ID for Product Group
 *
 *  @return returns the Product from the database.
 */
- (Product *) getProductForProductId: (int) productId withGroupId:(int) productGroupId;
- (Product *) getProductForProductIdFromProductGroups: (int) productId withGroupId:(int) productGroupId;
/*!
 *  Saves Container Ratin Images to DB
 */
- (void) saveContainerImagesToDB;
/*!
 *  Save Inspection from Summary Screen
 *
 *  @param inspectionName Inspection Names for resuming.
 */
- (void) saveInspection: (NSString *) inspectionName;
/*!
 *  Cancels Inspection: Removes all the saved audits, resets the Audit master ID and everything related to the current Inspection.
 */
- (void) cancelInspection;

/*!
 *  Method used to cancel an inspection. Is called when user hits back from the product select screen.
 */
- (void) cancelBackInspection;

/*!
 *  deletes PONumber from the Defaults manager.
 */
- (void) deletePONumberFromUserDefaults;
- (void) deleteGRNFromUserDefaults;
- (void) deleteOtherFromUserDefaults;
/*!
 *  Finish Inspection: Audits will be finalised and saved in the Audit database here.
 */
- (void) finishInspection;

-(void) deleteAuditWithId:(NSString*)productGroupId forAuditCount:(int)auditCount;

/*!
 *  This method returns a product object when we pass in the GroupId and ProductId
 *
 *  @param groupId   GroupId
 *  @param productId ProductId
 *
 *  @return Product object
 */
- (Product *) getProduct:(int) groupId withProductID:(int) productId;
- (void) clearOrderDataArray;
- (void) checkForPONumberAndSaveItInUserDefaults;
- (void) checkForGRNAndSaveItInUserDefaults;
- (void) checkForVendorNameAndSaveItInUserDefaults;
- (void) checkForOtherAndSaveItInUserDefaults: (BOOL) isOtherSelected;
- (BOOL) checkForSysco;
- (BOOL) checkIfProgramIsDistinctMode:(NSString*)programName;
- (NSArray *) groupSupplierNames: (NSArray *) productAudits;
- (NSArray *) removeProductGroupsIfItsOrderData: (NSArray *) productGroupsArrayLocal;


-(void) updateStarRatingWithScore:(int)newScore ratingId:(int)ratingId productId:(int)productId auditCount:(int)auditCount updateAll:(BOOL)updateAll;

-(void) convertAuditToFakeAudit:(int)productId auditCount:(int)auditCount;
- (BOOL)isNoneSelectedForPOSupplier;
- (BOOL)isNoneSelectedForGRNSupplier;
-(void)cleanupCollaborativeInspections;

//NonOrderData values
-(void)savePOForNonOrderDataInspection:(NSString*)poNumber;
-(void)saveGRNForNonOrderDataInspection:(NSString*)grn;
-(void)saveSupplierForNonOrderDataInspection:(NSString*)supplier;
-(void)resetNonOrderDataValues;

-(NSArray<AuditApiContainerRating> *) getContainerRatingsForInspection:(NSString *) auditMasterIdLocal;
- (void) saveAuditInOfflineTable:(Audit *) auditJson withImages:(NSString *) jsonString;


//------------------------------------------------------------------------------
// Class Methods
//------------------------------------------------------------------------------

// Class Methods
/*!
 *  Singleton instance for the inspection class.
 */
+ (Inspection *) sharedInspection;
@end
