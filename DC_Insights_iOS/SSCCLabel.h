//
//  SSCCLabel.h
//  Insights
//
//  Created by Mustafa Shaheen on 7/7/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCCLabel : NSObject
@property (nonatomic, strong) UIImage *barCode;
-(CIImage*)generateBarcode:(NSString*)dataString;
@end
