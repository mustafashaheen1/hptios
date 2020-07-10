//
//  RatingSelectSectionHeader.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 4/8/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "RatingSelectSectionHeader.h"
#import "SKSTableViewCellIndicator.h"

#define kIndicatorViewTag -1

@implementation RatingSelectSectionHeader

- (void)awakeFromNib {
    
    // set the selected image for the disclosure button
    self.checked = NO;
    
    //self.checkMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.checkMarkButton.frame = CGRectMake(9, 18, 23, 24);
    //[self.checkMarkButton setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    [self.checkMarkButton addTarget:self action:@selector(toggleCheckMarkOpenWithUserAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //self.defectValuesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.defectValuesButton.frame = CGRectMake(183, 8, 95, 44);
    [self.defectValuesButton addTarget:self action:@selector(defectValuesButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.defectValuesButton.layer.cornerRadius = 5.0;
    //self.defectValuesButton.backgroundColor = [UIColor grayColor];

    //self.defectValuesLabel = [[UILabel alloc] initWithFrame:CGRectMake(186, 12, 88, 36)];
    //self.defectValuesLabel.textColor = [UIColor whiteColor];
    self.defectValuesLabel.backgroundColor = [UIColor clearColor];
    //self.defectValuesLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.globalSeverities =[[NSMutableArray alloc]init];

}

- (IBAction)toggleOpen:(id)sender {
    [self toggleOpenWithUserAction:YES];
}

- (IBAction)toggleCheckMark:(id)sender {
    [self toggleCheckMarkOpenWithUserAction:YES];
}

- (IBAction)defectValuesButtonTouched:(id)sender {
    [self.delegate sectionHeaderView:self alertViewOpened:self.indexPath];
}

- (void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // toggle the disclosure button state
    self.collapseButton.selected = !self.collapseButton.selected;
    
    // if this was a user action, send the delegate the appropriate message
    if (self.collapseButton.selected) {
        if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
            [self.delegate sectionHeaderView:self sectionOpened:self.section];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
            [self.delegate sectionHeaderView:self sectionClosed:self.section];
        }
    }
}

- (void)toggleCheckMarkOpenWithUserAction:(BOOL)userAction {
    
    // toggle the disclosure button state
    self.checkMarkButton.selected = !self.checkMarkButton.selected;
    
    // if this was a user action, send the delegate the appropriate message
    if (self.checkMarkButton.selected) {
        [self.checkMarkButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateSelected];
        self.checked = YES;
        [self.delegate sectionHeaderView:self alertViewOpened:self.indexPath];
    }
    else {
        [self.checkMarkButton setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateSelected];
        self.checked = NO;
        [self.delegate sectionHeaderView:self alertViewClosed:self.indexPath];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setExpandable:NO];
        [self setExpanded:NO];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isExpanded) {
        
        if (![self containsIndicatorView])
            [self addIndicatorView];
        else {
            [self removeIndicatorView];
            [self addIndicatorView];
        }
    }
}

//static UIImage *_image = nil;
//- (UIView *)expandableView
//{
//    if (!_image) {
//        _image = [UIImage imageNamed:@"expandableImage.png"];
//    }
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGRect frame = CGRectMake(0.0, 0.0, _image.size.width, _image.size.height);
//    button.frame = frame;
//    
//    [button setBackgroundImage:_image forState:UIControlStateNormal];
//    
//    return button;
//}

- (void)setExpandable:(BOOL)isExpandable
{
//    if (isExpandable)
//        [self setAccessoryView:[self expandableView]];
    
    _expandable = isExpandable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)addIndicatorView
{
    CGPoint point = self.accessoryView.center;
    CGRect bounds = self.accessoryView.bounds;
    
    CGRect frame = CGRectMake((point.x - CGRectGetWidth(bounds) * 1.5), point.y * 1.4, CGRectGetWidth(bounds) * 3.0, CGRectGetHeight(self.bounds) - point.y * 1.4);
    SKSTableViewCellIndicator *indicatorView = [[SKSTableViewCellIndicator alloc] initWithFrame:frame];
    indicatorView.tag = kIndicatorViewTag;
    [self.contentView addSubview:indicatorView];
}

- (void)removeIndicatorView
{
    id indicatorView = [self.contentView viewWithTag:kIndicatorViewTag];
    [indicatorView removeFromSuperview];
}

- (BOOL)containsIndicatorView
{
    return [self.contentView viewWithTag:kIndicatorViewTag] ? YES : NO;
}

- (void)accessoryViewAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        if (self.isExpanded) {
            self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            self.accessoryView.transform = CGAffineTransformMakeRotation(0);
        }
    } completion:^(BOOL finished) {
        if (!self.isExpanded)
            [self removeIndicatorView];
    }];
}

@end
