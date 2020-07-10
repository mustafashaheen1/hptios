//
//  UIColor+UIColor_DCInsights.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/16/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

/*------------------------------------------------------------------------------
 CLASS: UIColor+DCInsights
 
 PURPOSE:
 UIColor extensions for Shopwell specific colors
 
 METHODS:
 
 
 -----------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>

#define kSWColorTSegmentSelectRed		((1.0 * 0x92) / (1.0 * 0xFF))
#define kSWColorTSegmentSelectGreen		((1.0 * 0x8B) / (1.0 * 0xFF))
#define kSWColorTSegmentSelectBlue		((1.0 * 0x7A) / (1.0 * 0XFF))

#define kSWColorLightGrayRed			((1.0 * 0x66) / (1.0 * 0xFF))
#define kSWColorLightGrayGreen			((1.0 * 0x66) / (1.0 * 0xFF))
#define kSWColorLightGrayBlue			((1.0 * 0x66) / (1.0 * 0xFF))

#define kSWColorMediumGrayRed			((1.0 * 0x50) / (1.0 * 0xFF))
#define kSWColorMediumGrayGreen			((1.0 * 0x4C) / (1.0 * 0xFF))
#define kSWColorMediumGrayBlue			((1.0 * 0x44) / (1.0 * 0xFF))

#define kSWColorListCellGrayRed			((1.0 * 0xEE) / (1.0 * 0xFF))
#define kSWColorListCellGrayGreen		((1.0 * 0xEE) / (1.0 * 0xFF))
#define kSWColorListCellGrayBlue		((1.0 * 0xEE) / (1.0 * 0xFF))

#define kSWColorDarkTextRed				((1.0 * 0x38) / (1.0 * 0xFF))
#define kSWColorDarkTextGreen			((1.0 * 0x35) / (1.0 * 0xFF))
#define kSWColorDarkTextBlue			((1.0 * 0x2E) / (1.0 * 0xFF))

#define kSWColorBSegmentNormalRed		((1.0 * 0xEA) / (1.0 * 0xFF))
#define kSWColorBSegmentNormalGreen		((1.0 * 0xE7) / (1.0 * 0xFF))
#define kSWColorBSegmentNormalBlue		((1.0 * 0xE4) / (1.0 * 0xFF))

#define kSWColorBSegmentSelectRed		((1.0 * 0xEA) / (1.0 * 0xFF))
#define kSWColorBSegmentSelectGreen		((1.0 * 0xE7) / (1.0 * 0xFF))
#define kSWColorBSegmentSelectBlue		((1.0 * 0xE4) / (1.0 * 0xFF))


#define kSWColorX1Red					((1.0 * 0x50) / (1.0 * 0xFF))
#define kSWColorX1Green					((1.0 * 0x4C) / (1.0 * 0xFF))
#define kSWColorX1Blue					((1.0 * 0x44) / (1.0 * 0xFF))


#define kSWColorX3Red					((1.0 * 0x66) / (1.0 * 0xFF))
#define kSWColorX3Green					((1.0 * 0x66) / (1.0 * 0xFF))
#define kSWColorX3Blue					((1.0 * 0x66) / (1.0 * 0xFF))

#define kSWColorListBGRed				((1.0 * 0xF8) / (1.0 * 0xFF))
#define kSWColorListBGGreen				((1.0 * 0xF7) / (1.0 * 0xFF))
#define kSWColorListBGBlue				((1.0 * 0xF6) / (1.0 * 0xFF))

#define kSWColorNavbarBGBGRed			((1.0 * 0x79) / (1.0 * 0xFF))
#define kSWColorNavbarBGGreen			((1.0 * 0x74) / (1.0 * 0xFF))
#define kSWColorNavbarBGBlue			((1.0 * 0x68) / (1.0 * 0xFF))

#define kSWColorNavbarButtonRed			((1.0 * 0x87) / (1.0 * 0xFF))
#define kSWColorNavbarButtonGreen		((1.0 * 0x81) / (1.0 * 0xFF))
#define kSWColorNavbarButtonBlue		((1.0 * 0x72) / (1.0 * 0xFF))

#define kSWColorSegmentButtonNRed		((1.0 * 0x92) / (1.0 * 0xFF))
#define kSWColorSegmentButtonNGreen		((1.0 * 0x8B) / (1.0 * 0xFF))
#define kSWColorSegmentButtonNBlue		((1.0 * 0x7A) / (1.0 * 0xFF))

#define kSWColorPageBodyBGRed           ((1.0 * 0xDB) / (1.0 * 0xFF))
#define kSWColorPageBodyBGGreen         ((1.0 * 0xD7) / (1.0 * 0xFF))
#define kSWColorPageBodyBGBlue          ((1.0 * 0xD2) / (1.0 * 0xFF))

#define kSWColorSectionBodyBGRed           ((1.0 * 0xE5) / (1.0 * 0xFF))
#define kSWColorSectionBodyBGGreen         ((1.0 * 0xE5) / (1.0 * 0xFF))
#define kSWColorSectionBodyBGBlue          ((1.0 * 0xE5) / (1.0 * 0xFF))

#define kSWColorTextFieldBGRed          ((1.0 * 0xF8) / (1.0 * 0xFF))
#define kSWColorTextFieldBGGreen        ((1.0 * 0xF7) / (1.0 * 0xFF))
#define kSWColorTextFieldBGBlue         ((1.0 * 0xF6) / (1.0 * 0xFF))

#define kSWColorTableCellHLRed          ((1.0 * 0xEA) / (1.0 * 0xFF))
#define kSWColorTableCellHLGreen        ((1.0 * 0xE7) / (1.0 * 0xFF))
#define kSWColorTableCellHLBlue         ((1.0 * 0xE4) / (1.0 * 0xFF))

@interface UIColor (UIColor_DCInsights)

+ (UIColor*) hex999999;
+ (UIColor*) hex463f35;
+ (UIColor*) hexfcfcfc;
+ (UIColor*) hex504c44;
+ (UIColor*) hexdbd7d2;
+ (UIColor*) hex67645d;
+ (UIColor*) hexdcdcdc;
+ (UIColor*) hexededed;
+ (UIColor*) hexe0ddd9;
+ (UIColor*) hexe0ddd9Hilite;

+ (UIColor*) whiteCellHilite;

+ (UIColor*) PlaceholderText;


+ (UIColor*) SWlightGray;
+ (UIColor*) SWmediumGray;
+ (UIColor*) SWlistCellGray;

+ (UIColor*) SWdarkText;

+ (UIColor*) segmentButtonNormal;
+ (UIColor*) segmentButtonSelected;

+ (UIColor*) segmentTextNormal;
+ (UIColor*) segmentTextSelected;

+ (UIColor*) labelMediumGray;

+ (UIColor*) listDropdownBackground;
+ (UIColor*) navbarBackground;
+ (UIColor*) navbarButtonBackgroud;

+ (UIColor*) pageBodyBackground;
+ (UIColor*) sectionBodyBackground;
+ (UIColor*) textFieldBackground;
+ (UIColor*) tableCellHighlight;

+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor*)colorWithHex:(NSInteger)hexValue;


+ (UIColor*) productTitle;
+ (UIColor*) productSubtitle;
+ (UIColor*) productCurrentlyInList;

+ (UIColor*) menuButtonFlash;
+ (UIColor*) menuTextFlash;


+ (UIColor*) x1;
+ (UIColor*) x3;

@end
