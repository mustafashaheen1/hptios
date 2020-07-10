//
//  SectionHeaderView.h
//  Insights
//
//  Created by Vineet on 3/28/19.
//  Copyright © 2019 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SectionHeaderViewDelegate <NSObject>
@optional
- (void)sectionHeaderView:(NSObject *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(NSObject *)sectionHeaderView sectionClosed:(NSInteger)section;
- (void)sectionHeaderView:(NSObject *)sectionHeaderView alertViewOpened:(NSIndexPath *)indexPath;
- (void)sectionHeaderView:(NSObject *)sectionHeaderView alertViewClosed:(NSIndexPath *)indexPath;
@end

@interface SectionHeaderView : NSObject

@end

