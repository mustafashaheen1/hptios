//
//  CompleteInspectionsListViewController.m
//  Insights
//
//  Created by Shyam Ashok on 12/28/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "CompleteInspectionsListViewController.h"
#import "Audit.h"
#import "CompleteInspectionSubTableViewCell.h"
#import "Store.h"
#import "Container.h"

@interface CompleteInspectionsListViewController ()

@end

@implementation CompleteInspectionsListViewController

@synthesize inspectionsListTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageTitle = @"CompleteInspectionsListViewController";
    [self setupNavBar];
    self.completeListArray = [[NSMutableArray alloc] init];
    //[self getCompleteInspectionsList];
    [self getAllInspections];
    // Do any additional setup after loading the view from its nib.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (void)viewDidAppear:(BOOL)animated
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        [self getAllSavedAudits];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });
    });
    [super viewDidAppear:animated];
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getAllInspections {
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.syncOverlay = [[SyncOverlayView alloc] initWithFrame:CGRectMake(0, 0, win.bounds.size.width, win.bounds.size.height)];
    self.syncOverlay.headingTitleLabel.text = @"Loading Inspections...";
    [win addSubview:self.syncOverlay];
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        [self getCompleteInspectionsList];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.syncOverlay dismissActivityView];
            [self.syncOverlay removeFromSuperview];
            [self.inspectionsListTableView reloadData];
        });
    });
}

- (void) getCompleteInspectionsList {
    // Get all the Audits from the Offline db
    NSArray *auditsArray = [self getAllTheRatingsNoMatterWhat];
    //NSLog(@"audit %@", auditsArray);
    
    //Get all the Unique Store Ids for these audits.
    NSMutableArray *groups = [auditsArray valueForKeyPath:@"@distinctUnionOfObjects.auditData.location.store.id"];
    //NSLog(@"grosfvsn %@", groups);
    NSMutableArray *groupsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *storeDict = [[NSMutableDictionary alloc] init];
    //After retrieving the Store Ids, create dictionaries where key is the store Id and value is the array of audits that is completed for the store.
    for (int i=0; i < [groups count]; i++) {
        NSNumber *storeId = [groups objectAtIndex:i];
        for (Audit *audit in auditsArray) {
            if ([storeId integerValue] == audit.auditData.location.store.id) {
                [groupsArray addObject:audit];
            }
        }
        [storeDict setObject:groupsArray forKey:storeId];
    }
    
    // retrieve all the keys from the dictionary
    NSArray *allKeys = [storeDict allKeys];
    NSMutableDictionary *containerDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *containerStoreDict = [[NSMutableDictionary alloc] init];
    //For every store id retreive all the container ratings.
    for (NSNumber *storeId in allKeys) {
        NSArray *groupsByStoreArray = [storeDict objectForKey:storeId];
        NSMutableArray *mutableContainerArray = [[NSMutableArray alloc] init];
        for (Audit *audit in groupsByStoreArray) {
            NSArray<AuditApiContainerRating>* containerRatings = audit.auditData.submittedInfo.containerRatings;
            [mutableContainerArray addObjectsFromArray:containerRatings];
        }
        //Get all the unique container ids from the ratings.
        NSMutableArray *containersGroup = [mutableContainerArray valueForKeyPath:@"@distinctUnionOfObjects.container_id"];
        //NSLog(@"verg %@", containersGroup);
        NSMutableArray *containersArray = [[NSMutableArray alloc] init];
        for (int i=0; i < [containersGroup count]; i++) {
            NSNumber *containerId = [containersGroup objectAtIndex:i];
            for (Audit *audit in groupsByStoreArray) {
                if ([audit.auditData.submittedInfo.containerRatings count] > 0) {
                    AuditApiContainerRating *containerRating = [audit.auditData.submittedInfo.containerRatings objectAtIndex:0];
                    if ([containerId integerValue] == containerRating.container_id) {
                        [containersArray addObject:audit];
                    }
                }
            }
            //Create a dictionary with key being the containerId and value being the array for containerrtings for the respective container id.
            [containerDict setObject:containersArray forKey:containerId];
        }
        //Repeat the same with Key being the storeId and value being the Dictionary created above.
        [containerStoreDict setObject:containerDict forKey:storeId];
    }
    
    for (NSString *storeID in containerStoreDict) {
        NSDictionary *containersDict = [containerStoreDict objectForKey:storeID];
        NSMutableArray *containersArrayForStore = [[NSMutableArray alloc] init];
        for (NSString *containerIdKey in containersDict) {
            NSArray *audits = [containersDict objectForKey:containerIdKey];
            NSMutableArray *arrayStrings = [[NSMutableArray alloc] init];
            // Create array of strings to display in the tableview
            for (Audit *audit in audits) {
                NSArray<AuditApiContainerRating> *containerRatingsLocalArray = audit.auditData.submittedInfo.containerRatings;
                NSString *stringRating = @"";
                for (AuditApiContainerRating *containerRating in containerRatingsLocalArray) {
                    stringRating = [stringRating stringByAppendingString: [NSString stringWithFormat:@"%@ / ", containerRating.value]];
                }
                if ([[NSString stringWithFormat:@"%@", storeID] isEqualToString:[NSString stringWithFormat:@"%d", audit.auditData.location.store.id]]) {
                    [arrayStrings addObject:stringRating];
                }
            }
            NSLog(@"cojwr f%@", arrayStrings);
            //Find out the number of times, the strings are being repeated.
            NSCountedSet *countedSet = [NSCountedSet setWithArray:arrayStrings];
            __block NSUInteger totalNumberOfDuplicates = 0;
            NSMutableArray *arrayStringsFinal = [[NSMutableArray alloc] init];
            [countedSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                NSUInteger duplicateCountForObject = [countedSet countForObject:obj];
                if (duplicateCountForObject > 1)
                    totalNumberOfDuplicates += duplicateCountForObject;
                //NSLog(@"%@ appears %d times", obj, duplicateCountForObject);
                NSString *finalStringFormat = [NSString stringWithFormat:@"%@%d", obj, duplicateCountForObject];
                [arrayStringsFinal addObject:finalStringFormat];
            }];
            NSArray* nonMutableCopy = [arrayStringsFinal copy];
            nonMutableCopy= [nonMutableCopy sortedArrayUsingSelector:@selector(compare:)];
            arrayStringsFinal = [nonMutableCopy mutableCopy];
            
            //NSLog(@"Total number of duplicates is %@", arrayStringsFinal);
            // From the container ids find out the container name
            NSString *containerName = [Container getContainerNameFromContainerId:containerIdKey];
            NSDictionary *dictContainer = @{containerName : arrayStringsFinal};
            [containersArrayForStore addObject:dictContainer];
           
        }
        // From the store ids find out the store name
        NSString *storeIdName = [NSString stringWithFormat:@"%@ / %@",[Store getStoreNameFromStoreId:storeID], [NSUserDefaultsManager getObjectFromUserDeafults:usernameForLogoutSaved]];
        NSDictionary *dictContainer = @{storeIdName : containersArrayForStore};
        [self.completeListArray addObject:dictContainer];
     
    }
}

- (NSArray *) getAllTheRatingsNoMatterWhat {
    NSString *queryAllOfflineRatings = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", TBL_COMPLETED_AUDITS, COL_DATA_SUBMITTED, CONST_FALSE];
    int count = 0;
    NSMutableArray *auditsArray = [[NSMutableArray alloc] init];
    FMDatabase *databaseOfflineRatings = [[DBManager sharedDBManager] openDatabase:DB_OFFLINE_DATA];
    FMResultSet *resultsGroupRatings;
    [databaseOfflineRatings open];
    resultsGroupRatings = [databaseOfflineRatings executeQuery:queryAllOfflineRatings];
    while ([resultsGroupRatings next]) {
        count++;
        NSString *ratings = [resultsGroupRatings stringForColumn:COL_RATINGS];
        //NSLog(@"CompletedInspections: %d - %@", count, ratings);
        Audit *audit = [[Audit alloc] initWithString:ratings error:nil];
        if(audit) //fix for crash sometimes
        [auditsArray addObject:audit];
    }
    [databaseOfflineRatings close];
    return auditsArray;
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.completeListArray count];    //count of section
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = [self.completeListArray objectAtIndex:section];
    return [NSString stringWithFormat:@"%@", [[dict allKeys] objectAtIndex:0]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dict = [self.completeListArray objectAtIndex:section];
    NSArray *array = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
    int countForRows = [array count];
    for (NSDictionary *dictLocal in array) {
        NSArray *stringsArray = [dictLocal objectForKey:[[dictLocal allKeys] objectAtIndex:0]];
        countForRows = countForRows + [stringsArray count];
    }
    //NSLog(@"fvdv %@", array);
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CompleteInspectionSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompleteInspectionSubTableViewCell"];
    if(!cell)
        cell = [[CompleteInspectionSubTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CompleteInspectionSubTableViewCell"];
    NSDictionary *dict = [self.completeListArray objectAtIndex:indexPath.section];
    NSArray *array = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
    cell.containersGLobalArray = array;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.completeListArray objectAtIndex:indexPath.section];
    NSArray *array = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
    int countForRows = [array count];
    for (NSDictionary *dictLocal in array) {
        NSArray *stringsArray = [dictLocal objectForKey:[[dictLocal allKeys] objectAtIndex:0]];
        countForRows = countForRows + [stringsArray count];
    }
    return countForRows*30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (IBAction)removeView:(id)sender {
    [self.view removeFromSuperview];
}


@end
