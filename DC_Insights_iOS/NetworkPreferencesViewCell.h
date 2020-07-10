//
//  NetworkPreferencesViewCell.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/18/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TestConnectionDelegate <NSObject>
- (void) testConnectionDelegateTouched;
@end

@interface NetworkPreferencesViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *testConnectionButton;
@property (strong, nonatomic) id <TestConnectionDelegate> delegate;

- (void)refreshState;
- (IBAction)testConnectionButtonTouched:(id)sender;

@end
