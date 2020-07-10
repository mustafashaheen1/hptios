//
//  ProductListItem.h
//  Insights
//
//  Created by Vineet Pareek on 8/3/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import "OrderData.h"
#import "SavedAudit.h"

@interface ProductListItem : NSObject
//name/sku/itemNumber/PO/Supplier/isCollaborative/isFlagged/auditsCompleted
@property Product *product;
@property OrderData *orderData;
@property SavedAudit *savedAudit;
@property NSString* poNumber;
@property NSString* supplier;
@property int collaborativeInspectionStatus;
@property NSString* collaborativeInspectionMessage;

@end
