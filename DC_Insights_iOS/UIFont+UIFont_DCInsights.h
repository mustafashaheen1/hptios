//
//  UIFont+UIFont_DCInsights.h
//  DC_Insights_iOS
//
//  Created by Shyam Ashok on 3/16/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

/*------------------------------------------------------------------------------
 CLASS: UIFont+DCInsights
 
 PURPOSE:
 UIFont extensions for Shopwell specific colors
 
 METHODS:
 
 
 -----------------------------------------------------------------------------*/


#import <Foundation/Foundation.h>

#define KSWFontNameUnivers39		@"UniversLT-ThinUltraCondensed"
#define KSWFontNameUnivers45Oblique	@"UniversCom-45LightOblique"
#define KSWFontNameUnivers47		@"UniversCom-47LightCond"
#define KSWFontNameUnivers47Oblique	@"UniversCom-47LightCondObl"
#define KSWFontNameUnivers57		@"UniversCom-57Condensed"
#define kSWFontNameUnivers59		@"UniversCom-59UltraCondensed"
#define KSWFontNameUnivers67		@"UniversCom-67BoldCond"

@interface UIFont (UIFont_DCInsights)

// Main Styles
// NOTE: styles are in points, actual pixel sizes are half the number

// UniverseLT 39

+ (UIFont*) thirtyNineAt40;
+ (UIFont*) thirtyNineAt50;
+ (UIFont*) thirtyNineAt80;
+ (UIFont*) thirtyNineAt120;

// Univers 59
+ (UIFont*) fiftyNineAt28;
+ (UIFont*) fiftyNineAt44;
+ (UIFont*) fiftyNineAt52;
+ (UIFont*) fiftyNineAt80;

// Univers 57
+ (UIFont*) fiftySevenAt22;
+ (UIFont*) fiftySevenAt24;
+ (UIFont*) fiftySevenAt26;
+ (UIFont*) fiftySevenAt28;
+ (UIFont*) fiftySevenAt32;


// Univers 47
+ (UIFont*) fortySevenAt20;
+ (UIFont*) fortySevenAt24;
+ (UIFont*) fortySevenAt26;
+ (UIFont*) fortySevenAt28;
+ (UIFont*) fortySevenAt30;
+ (UIFont*) fortySevenAt32;
+ (UIFont*) fortySevenAt35;
+ (UIFont*) fortySevenAt36;
+ (UIFont*) fortySevenAt48;
+ (UIFont*) fortySevenAt50;


// Univers 47 Light Oblique
+ (UIFont*) fortySevenObliqueAt28;




+ (UIFont*) navbarMain;
+ (UIFont*) navbarAux;
+ (UIFont*) navbarButton;

+ (UIFont*) segmentButtonNormal;


+ (UIFont*) bigScore;
+ (UIFont*) smallScore;
+ (UIFont*) smallScoreForNA;
+ (UIFont*) mediumScore;
+ (UIFont*) mediumScoreForNA;


+ (UIFont*) tableHeader;


// Product list
+ (UIFont*) productListItemTitle;
+ (UIFont*) productListItemDescription;
+ (UIFont*) productListCurrentInList;

// Shopping List
+ (UIFont*) shoppingListListMenu;
+ (UIFont*) shoppingListListMenuCurrent;

// Product Detail
+ (UIFont*) fitScoreDescription;
+ (UIFont*) detailTitle;
+ (UIFont*) detailSubtitle;
+ (UIFont*) detailLastPurchased;
+ (UIFont*) detailQuantity;
+ (UIFont*) alternativesLabel;
+ (UIFont*) oneShoppingList;
+ (UIFont*) shoppingListDetailName;
+ (UIFont*) tellMeWhyDescription;

// Ingredients and Nutrition Facts
+ (UIFont*) dataWebViewKeyLabel;

// Error View
+ (UIFont*) errorViewTitle;
+ (UIFont*) errorViewDescription;
+ (UIFont*) errorViewButton;

// Browse
+ (UIFont*) metacategoryName;
+ (UIFont*) categoryName;

+ (UIFont*) mainMenuLabel;
+ (UIFont*) mainMenuButton;
+ (UIFont*) aboutMenuVersion;
+ (UIFont*) aboutMenuTitle;
+ (UIFont*) aboutMenuBody;


@end
