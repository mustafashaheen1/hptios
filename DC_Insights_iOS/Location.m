//
//  Location.m
//  Insights
//
//  Created by Mustafa Shaheen on 6/30/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "Location.h"
#import "LocationAPI.h"
@implementation Location
@synthesize location_id;
@synthesize name;
@synthesize store_number;
@synthesize address;
@synthesize postal_code;
@synthesize city;
@synthesize state;
@synthesize country;
@synthesize geo_point;
@synthesize marketing_sales_area;
@synthesize sales_volume;
@synthesize banner_id;
@synthesize short_name;
@synthesize company_id;
@synthesize archived;
@synthesize gln;

- (id)init
{
    self = [super init];
    if (self) {
        self.location_id = 0;
        self.name = @"";
        self.store_number = 0;
        self.address = @"";
        self.postal_code = 0;
        self.city = @"";
        self.state = @"";
        self.country = @"";
        self.geo_point = @"";
        self.marketing_sales_area = @"";
        self.sales_volume = @"";
        self.banner_id = @"";
        self.short_name = @"";
        self.company_id = 0;
        self.archived = NO;
        self.gln = @"";
    }
    return self;
}


#pragma mark - CallToServer

/*------------------------------------------------------------------------------
 Get Locations
 -----------------------------------------------------------------------------*/

- (void)locationCallWithBlock:(void (^)(NSArray *locations, NSError *error))block {
    LocationAPI *locationAPI = [[LocationAPI alloc] init];
    [locationAPI locationCallWithBlock:^(BOOL isSuccess, NSArray *locationsLocal, NSError *error){
        if (error) {
            DebugLog(@"\n Error: %@  \n", [error localizedDescription]);
        } else {
            [self getLocationsFromArray:locationsLocal];
        }
    }];
}

#pragma mark - JSON Methods

- (void)setLocationAttributesFromMap:(NSString*)dataMap {
    if (dataMap) {
        self.location_id = [dataMap integerValue];
    }
}


+ (NSString *) getLocationNameFromLocationId: (NSString *) locationIDLocal {
    FMDatabase *databaseGroupRatings = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    [databaseGroupRatings open];
    results = [databaseGroupRatings executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE id=%@", TBL_LOCATIONS, locationIDLocal]];
    NSString *nameLocal = @"";
    while ([results next]) {
        nameLocal = [results stringForColumn:@"name"];
    }
    [databaseGroupRatings close];
    return nameLocal;
}
@end
