//
//  ASStarRatingView.h
//

#import <UIKit/UIKit.h>

#define kDefaultMaxRating 5
#define kDefaultLeftMargin 5
#define kDefaultMidMargin 5
#define kDefaultRightMargin 5
#define kDefaultMinAllowedRating 0
#define kDefaultMaxAllowedRating kDefaultMaxRating
#define kDefaultMinStarSize CGSizeMake(5, 5)

@protocol ASStarRatingViewProtocol <NSObject>

- (void)ratingChanged;

@end


@interface ASStarRatingView : UIView {
    UIImage *_notSelectedStar;
    UIImage *_selectedStar;
    UIImage *_halfSelectedStar;
    BOOL _canEdit;
    int _maxRating;
    float _leftMargin;
    float _midMargin;
    float _rightMargin;
    CGSize _minStarSize;
    float _rating;
    float _minAllowedRating;
    float _maxAllowedRating;
    NSMutableArray *_starViews;
}

@property (weak, nonatomic) id <ASStarRatingViewProtocol> delegate;

@property (retain, nonatomic) UIImage *notSelectedStar;
@property (retain, nonatomic) UIImage *selectedStar;
@property (retain, nonatomic) UIImage *halfSelectedStar;
@property (assign, nonatomic) BOOL canEdit;
@property (assign, nonatomic) int maxRating;
@property (assign, nonatomic) float leftMargin;
@property (assign, nonatomic) float midMargin;
@property (assign, nonatomic) float rightMargin;
@property (assign, nonatomic) CGSize minStarSize;
@property (assign, nonatomic) float rating;
@property (assign, nonatomic) float minAllowedRating;
@property (assign, nonatomic) float maxAllowedRating;
@end