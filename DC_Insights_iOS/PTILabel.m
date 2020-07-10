//
//  PTILabel.m
//  Insights
//
//  Created by Mustafa Shaheen on 7/7/20.
//  Copyright © 2020 Yottamark. All rights reserved.
//

#import "PTILabel.h"

@implementation PTILabel

@synthesize barCode;
-(CIImage*)generateBarcode:(NSString*)dataString{

CIFilter *barCodeFilter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
NSData *barCodeData = [dataString dataUsingEncoding:NSASCIIStringEncoding];
[barCodeFilter setValue:barCodeData forKey:@"inputMessage"];
[barCodeFilter setValue:[NSNumber numberWithFloat:0] forKey:@"inputQuietSpace"];

CIImage *barCodeImage = barCodeFilter.outputImage;
return barCodeImage;
}
@end
