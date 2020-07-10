//
//  FlaggedMessage.h
//  Insights
//
//  Created by Vineet on 10/23/17.
//  Copyright © 2017 Yottamark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncOverlayView.h"
#import "DCBaseEntity.h"

@interface FlaggedMessage : UIView<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainview;
@property (weak, nonatomic) IBOutlet UITableView *flaggedMessageTableView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong,nonatomic) NSMutableArray *flaggedMessages;
@property (strong,nonatomic) NSMutableArray *messageObjectArray;
@property (nonatomic, strong) SyncOverlayView *syncOverlayView;

-(void)parseRawMessages;
-(int)getHeightForContent;
@end
