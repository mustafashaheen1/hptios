//
//  UserSelectViewController.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/5/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "UserSelectViewController.h"

@interface UserSelectViewController ()
@property (nonatomic, assign) int selectedUserIndex;
@end

@implementation UserSelectViewController
@synthesize userPicker;
@synthesize usersArray;
@synthesize delegate;
@synthesize selectedUserIndex;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)loadUsers
{
    usersArray = [[NSArray alloc] initWithObjects:
                  @"AHuff",
                  @"ALogan",
                  @"APalmer",
                  @"AutomationUser_939",
                  @"BEmperly",
                  @"bherdeman",
                  nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    userPicker.delegate = self;
    userPicker.dataSource = self;
    CGAffineTransform t0 = CGAffineTransformMakeTranslation (0, userPicker.bounds.size.height/2);
    CGAffineTransform s0 = CGAffineTransformMakeScale       (1.5, 1.5);
    CGAffineTransform t1 = CGAffineTransformMakeTranslation (0, -userPicker.bounds.size.height/2);
    userPicker.transform = CGAffineTransformConcat          (t0, CGAffineTransformConcat(s0, t1));
    [self loadUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIPickerView DataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [usersArray count];
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [usersArray objectAtIndex:row];
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    NSLog(@"Chosen item: %@", [usersArray objectAtIndex:row]);
    selectedUserIndex = row;
    
}

- (IBAction)done:(id)sender {
    User *user = [[User alloc] init];
    [self.delegate userSelectViewController: self didAddUser:(User *) user];
}

- (IBAction)cancel:(id)sender {
    [self.delegate userSelectViewControllerDidCancel:self];
}
@end
