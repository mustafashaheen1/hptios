//
//  HPTLabel.m
//  Insights
//
//  Created by Mustafa Shaheen on 7/7/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "HPTLabel.h"
#import "PTILabel.h"
@implementation HPTLabel


- (id)init
{
    self = [super init];
    if (self) {
        self.ptiLabels = [[NSMutableArray alloc] init];
        self.sscc = [[SSCCLabel alloc] init];
    }
    return self;
}
-(void) setPtiLabels: (NSArray *) caseCodes{
    PTILabel *ptiLabel = [[PTILabel alloc] init];
    
    for(NSString *caseCode in caseCodes){
        ptiLabel.barCode = [UIImage imageWithCIImage:[ptiLabel generateBarcode:caseCode]];
        [self.ptiLabels addObject:ptiLabel];
    }
}
-(void) setSSCCLabel: (NSString *) ssccTag{
    
    self.sscc.barCode = [UIImage imageWithCIImage:[self.sscc generateBarcode:ssccTag]];
}
@end
