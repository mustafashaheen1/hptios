//
//  UIColor+UIColor_DCInsights.m
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/16/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "UIColor+UIColor_DCInsights.h"

@implementation UIColor (UIColor_DCInsights)

+ (UIColor*) hex999999
{
	static UIColor *SWhex999999 = nil;
	
	if (SWhex999999 == nil)
		SWhex999999 = [UIColor colorWithHex:0x999999];
	
	return SWhex999999;
}

+ (UIColor*) hex463f35
{
	static UIColor *SWhex463f35 = nil;
	
	if (SWhex463f35 == nil)
		SWhex463f35 = [UIColor colorWithHex:0x463F35];
	
	return SWhex463f35;
}

+ (UIColor*) hexfcfcfc
{
	static UIColor *SWhexfcfcfc = nil;
	
	if (SWhexfcfcfc == nil)
		SWhexfcfcfc = [UIColor colorWithHex:0xFCFCFC];
	
	return SWhexfcfcfc;
}

+ (UIColor*) hex504c44
{
	static UIColor *SWhex504c44 = nil;
	
	if (SWhex504c44 == nil)
		SWhex504c44 = [UIColor colorWithHex:0x504C44];
	
	return SWhex504c44;
}

+ (UIColor*) hexdbd7d2
{
	static UIColor *SWhexd0ccc7 = nil;
	
	if (SWhexd0ccc7 == nil)
		SWhexd0ccc7 = [UIColor colorWithHex:0xDBD7D2];
	
	return SWhexd0ccc7;
}

+ (UIColor*) hex67645d
{
	static UIColor *SWhex67645d = nil;
	
	if (SWhex67645d == nil)
		SWhex67645d = [UIColor colorWithHex:0x57545D];
	
	return SWhex67645d;
}


+ (UIColor*) hexdcdcdc
{
	static UIColor *SWhexdcdcdc = nil;
	
	if (SWhexdcdcdc == nil)
		SWhexdcdcdc = [UIColor colorWithHex:0xDCDCDC];
	
	return SWhexdcdcdc;
}


+ (UIColor*) hexededed
{
	static UIColor *SWhexededed = nil;
	
	if (SWhexededed == nil)
		SWhexededed = [UIColor colorWithHex:0xEDEDED];
	
	return SWhexededed;
}


+ (UIColor*) hexe0ddd9
{
	static UIColor *SWhexe0ddd9 = nil;
	
	if (SWhexe0ddd9 == nil)
		SWhexe0ddd9 = [UIColor colorWithHex:0xe0ddd9];
	
	return SWhexe0ddd9;
}


+ (UIColor*) hexe0ddd9Hilite
{
	static UIColor *SWhexe0ddd9Hilite = nil;
	
	if (SWhexe0ddd9Hilite == nil)
		SWhexe0ddd9Hilite = [UIColor colorWithHex:0xE6E4E1];
	
	return SWhexe0ddd9Hilite;
}



+ (UIColor*) whiteCellHilite
{
	static UIColor *SWwhiteCellHilite = nil;
	
	if (SWwhiteCellHilite == nil) {
		UIImage *hilitePattern = [UIImage
								  imageNamed:@"dropdown_button_highlight.jpg"];
		SWwhiteCellHilite = [UIColor colorWithPatternImage:hilitePattern];
	}
	
	return SWwhiteCellHilite;
}


+ (UIColor*) PlaceholderText
{
	static UIColor *SWSPlaceholderText = nil;
	
	if (SWSPlaceholderText == nil)
		SWSPlaceholderText = [UIColor colorWithHex:0xB3B3B3];
	
	return SWSPlaceholderText;
}




+ (UIColor*) SWlightGray
{
	static UIColor *SWSWlightGray = nil;
	
	if (SWSWlightGray == nil)
		SWSWlightGray = [[UIColor alloc]
						 initWithRed:kSWColorLightGrayRed
						 green:kSWColorLightGrayGreen
						 blue:kSWColorLightGrayBlue
						 alpha:1.0];
	return SWSWlightGray;
}


+ (UIColor*) SWmediumGray
{
	static UIColor *SWSWmediumGray = nil;
	
	if (SWSWmediumGray == nil)
		SWSWmediumGray = [[UIColor alloc]
                          initWithRed:kSWColorMediumGrayRed
                          green:kSWColorMediumGrayGreen
                          blue:kSWColorMediumGrayBlue
                          alpha:1.0];
	return SWSWmediumGray;
}


+ (UIColor*) SWlistCellGray
{
	static UIColor *SWSWlistCellGray = nil;
	
	if (SWSWlistCellGray == nil)
		SWSWlistCellGray = [[UIColor alloc]
							initWithRed:kSWColorListCellGrayRed
							green:kSWColorListCellGrayGreen
							blue:kSWColorListCellGrayBlue
							alpha:1.0];
	return SWSWlistCellGray;
}


+ (UIColor*) SWdarkText
{
	static UIColor *SWSWdarkText = nil;
	
	if (SWSWdarkText == nil)
		SWSWdarkText = [[UIColor alloc]
                        initWithRed:kSWColorDarkTextRed
                        green:kSWColorDarkTextGreen
                        blue:kSWColorDarkTextBlue
                        alpha:1.0];
	return SWSWdarkText;
}



+ (UIColor*) segmentButtonNormal
{
	static UIColor *SWsegmentButtonNormal = nil;
	
	if (SWsegmentButtonNormal == nil)
		SWsegmentButtonNormal = [[UIColor alloc]
                                 initWithRed:kSWColorBSegmentNormalRed
                                 green:kSWColorBSegmentNormalGreen
                                 blue:kSWColorBSegmentNormalBlue
                                 alpha:1.0];
	return SWsegmentButtonNormal;
}


+ (UIColor*) segmentButtonSelected
{
	static UIColor *SWsegmentButtonSelected = nil;
	
	if (SWsegmentButtonSelected == nil)
		SWsegmentButtonSelected = [[UIColor alloc]
								   initWithRed:kSWColorBSegmentSelectRed
								   green:kSWColorBSegmentSelectGreen
								   blue:kSWColorBSegmentSelectBlue
								   alpha:1.0];
	return SWsegmentButtonSelected;
}


+ (UIColor*) segmentTextNormal
{
	return [UIColor SWmediumGray];
}


+ (UIColor*) segmentTextSelected
{
	static UIColor *SWsegmentTextSelected = nil;
	
	if (SWsegmentTextSelected == nil)
		SWsegmentTextSelected = [[UIColor alloc]
                                 initWithRed:kSWColorTSegmentSelectRed
                                 green:kSWColorTSegmentSelectGreen
                                 blue:kSWColorTSegmentSelectBlue
                                 alpha:1.0];
	return SWsegmentTextSelected;
}


+ (UIColor*) labelMediumGray
{
	static UIColor *SWlabelMediumGray = nil;
	
	if (SWlabelMediumGray == nil)
		SWlabelMediumGray = [UIColor colorWithHex:0x5B5B5B];
	return SWlabelMediumGray;
}


+ (UIColor*) productTitle
{
	static UIColor *SWproductTitle = nil;
	
	if (SWproductTitle == nil) {
        
        SWproductTitle = [UIColor colorWithHex:0x232323];
    }
    
	return SWproductTitle;
}


+ (UIColor*) productSubtitle
{
	static UIColor *SWproductSubtitle = nil;
	
	if (SWproductSubtitle == nil) {
        
        SWproductSubtitle = [UIColor colorWithHex:0x38352e];
    }
    
	return SWproductSubtitle;
}


+ (UIColor*) productCurrentlyInList
{
	static UIColor *SWproductCurrentlyInList = nil;
	
	if (SWproductCurrentlyInList == nil) {
        
        SWproductCurrentlyInList = [UIColor colorWithHex:0x38352e];
    }
    
	return SWproductCurrentlyInList;
}



+ (UIColor*) x1
{
	static UIColor *SWx1 = nil;
	
	if (SWx1 == nil)
		SWx1 = [[UIColor alloc] initWithRed:kSWColorX1Red
									  green:kSWColorX1Green
									   blue:kSWColorX1Blue
									  alpha:1.0];
	return SWx1;
}



+ (UIColor*) x3
{
	static UIColor *SWx3 = nil;
	
	if (SWx3 == nil)
		SWx3 = [[UIColor alloc] initWithRed:kSWColorX3Red
									  green:kSWColorX3Green
									   blue:kSWColorX3Blue
									  alpha:1.0];
	return SWx3;
}

+ (UIColor*) pageBodyBackground
{
	static UIColor *SWpageBodyBackground = nil;
	
	if (SWpageBodyBackground == nil)
		SWpageBodyBackground = [[UIColor alloc] initWithRed:kSWColorPageBodyBGRed
                                                      green:kSWColorPageBodyBGGreen
                                                       blue:kSWColorPageBodyBGBlue
                                                      alpha:1.0];
	return SWpageBodyBackground;
}

+ (UIColor*) sectionBodyBackground
{
	static UIColor *SWsectionBodyBackground = nil;
	
	if (SWsectionBodyBackground == nil)
		SWsectionBodyBackground = [[UIColor alloc] initWithRed:kSWColorSectionBodyBGRed
                                                         green:kSWColorSectionBodyBGGreen
                                                          blue:kSWColorSectionBodyBGBlue
                                                         alpha:1.0];
	return SWsectionBodyBackground;
}

+ (UIColor*) textFieldBackground
{
	static UIColor *SWtextFieldBackground = nil;
	
	if (SWtextFieldBackground == nil)
		SWtextFieldBackground = [[UIColor alloc] initWithRed:kSWColorTextFieldBGRed
                                                       green:kSWColorTextFieldBGGreen
                                                        blue:kSWColorTextFieldBGBlue
                                                       alpha:1.0];
	return SWtextFieldBackground;
}

+ (UIColor*) tableCellHighlight
{
	static UIColor *SWtableCellHighlight = nil;
	
	if (SWtableCellHighlight == nil)
		SWtableCellHighlight = [[UIColor alloc] initWithRed:kSWColorTableCellHLRed
                                                      green:kSWColorTableCellHLGreen
                                                       blue:kSWColorTableCellHLBlue
                                                      alpha:1.0];
	return SWtableCellHighlight;
}

+ (UIColor*) listDropdownBackground
{
	static UIColor *SWlistDropdownBackground = nil;
	
	if (SWlistDropdownBackground == nil)
		SWlistDropdownBackground = [[UIColor alloc] initWithRed:kSWColorListBGRed
														  green:kSWColorListBGGreen
														   blue:kSWColorListBGBlue
														  alpha:1.0];
	return SWlistDropdownBackground;
}


+ (UIColor*) navbarBackground
{
	static UIColor *SWnavbarBackground = nil;
	
	if (SWnavbarBackground == nil)
		SWnavbarBackground = [[UIColor alloc] initWithRed:kSWColorNavbarBGBGRed
													green:kSWColorNavbarBGGreen
													 blue:kSWColorNavbarBGBlue
													alpha:1.0];
	return SWnavbarBackground;
}


+ (UIColor*) menuButtonFlash
{
	static UIColor *SWmenuButtonFlash = nil;
	
	if (SWmenuButtonFlash == nil)
		SWmenuButtonFlash = [[UIColor alloc] initWithRed:145.0 / 255.0
												   green:189.0 / 255.0
													blue:1.0 / 255.0
												   alpha:1.0];
	return SWmenuButtonFlash;
}


+ (UIColor*) menuTextFlash
{
	static UIColor *SWmenuTextFlash = nil;
	
	if (SWmenuTextFlash == nil)
		SWmenuTextFlash = [[UIColor alloc] initWithRed:1.0
                                                 green:1.0
                                                  blue:1.0
                                                 alpha:0.6];
	return SWmenuTextFlash;
}


+ (UIColor*) navbarButtonBackgroud
{
	static UIColor *SWnavbarButtonBackgroud = nil;
	
	if (SWnavbarButtonBackgroud == nil)
		SWnavbarButtonBackgroud = [[UIColor alloc] initWithRed:kSWColorNavbarButtonRed
                                                         green:kSWColorNavbarButtonGreen
                                                          blue:kSWColorNavbarButtonBlue
                                                         alpha:1.0];
	return SWnavbarButtonBackgroud;
}




+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [[UIColor alloc] initWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                                  green:((float)((hexValue & 0xFF00) >> 8))/255.0
                                   blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*)colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}


@end
