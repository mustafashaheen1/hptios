//
//  CellDefects.m
//  DC_Insights_iOS
//
//  Created by John Gifford on 11/12/13.
//  Copyright (c) 2013 Yottamark. All rights reserved.
//

#import "DefectsViewCell.h"
#import "Image.h"

@implementation DefectsViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshState {
    self.descriptionLabel.text = self.defect.description;
    self.descriptionLabel.layer.borderWidth = 1.0;
    self.descriptionLabel.layer.borderColor = [[UIColor blackColor] CGColor];
//    UIImage *imageLocal = [self checkForImage];
//    if (!imageLocal) {
//        self.contentView.frame = CGRectMake(0, 0, 320, 384);
//        self.defectImage.frame = CGRectZero;
//        self.descriptionLabel.frame = CGRectMake(0, 0, 320, 384);
//    }
}

- (UIImage *) checkForImage {
    FMDatabase *database = [[DBManager sharedDBManager] openDatabase:DB_INSIGHTS_DATA];
    FMResultSet *results;
    UIImage *imageLocal;
    [database open];
    results = [database executeQuery:[self retrieveImagesFromDBForDefects]];
    while ([results next]) {
        if (self.defect.defectID == [results intForColumn:COL_ID]) {
            Image *image = [[Image alloc] init];
            image.deviceUrl = [results stringForColumn:COL_DEVICE_URL];
            imageLocal = [image getImageFromDeviceUrl];
        }
    }
    [database close];
    return imageLocal;
}

#pragma mark - SQL Retrieve Data Methods

- (NSString *) retrieveImagesFromDBForDefects {
    NSString *retrieveStatement = [NSString stringWithFormat:@"SELECT * FROM %@", TBL_DEFECT_IMAGES];
    return retrieveStatement;
}


@end
