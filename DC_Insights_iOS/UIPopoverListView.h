//
//  UIPopoverListView.h
//  UIPopoverListViewDemo
//
//  Created by su xinde on 13-3-13.
//  Copyright (c) 2013年 su xinde. All rights reserved.
//
//  DCInsights note:  This is an external library for displaying
//  a popover view, similar to android spinner widget.  

@class UIPopoverListView;

@protocol UIPopoverListViewDataSource <NSObject>
@required

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section;

- (void) textFieldText: (NSString *) text withTableView:(UITableView *) tableView;

@end

@protocol UIPopoverListViewDelegate <NSObject>
@optional

- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath;

- (void)popoverListViewCancel:(UIPopoverListView *)popoverListView;

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface UIPopoverListView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UITextViewDelegate>
{
    UITableView *_listView;
    UILabel     *_titleView;
    UIControl   *_overlayView;
    UITextField     *_textField;

    id<UIPopoverListViewDataSource> datasource;
    id<UIPopoverListViewDelegate>   delegate;
    
}

@property (nonatomic, assign) id<UIPopoverListViewDataSource> datasource;
@property (nonatomic, assign) id<UIPopoverListViewDelegate>   delegate;

@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) UITextField *_textField;
@property (nonatomic, assign) BOOL textFieldNeeded;
@property (nonatomic, assign) BOOL refreshButtoneeded;
@property (nonatomic, assign) BOOL isNumeric;

- (id)initWithFrame:(CGRect)frame withTextField: (BOOL) textFieldNeededLocal isRefreshNeeded:(BOOL)refresh;
- (void)setTitle:(NSString *)title;

- (void)show;
- (void)dismiss;

@end
