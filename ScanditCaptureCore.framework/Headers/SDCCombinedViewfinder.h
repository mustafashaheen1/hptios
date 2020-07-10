/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCViewfinder.h>

#import <UIKit/UIColor.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.3.0
 *
 * A viewfinder that is a container for other viewfinders. It allows you to have multiple viewfinders in one overlay.
 *
 * To use this viewfinder, create a new instance of it and assign it to the overlay, e.g. assign it to the barcode capture overlay with the SDCBarcodeCaptureOverlay.viewfinder property.
 */
NS_SWIFT_NAME(CombinedViewfinder)
SDC_EXPORTED_SYMBOL
@interface SDCCombinedViewfinder : NSObject <SDCViewfinder>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
/**
 * Added in version 6.3.0
 *
 * Returns a new combined viewfinder.
 */
+ (nonnull instancetype)viewfinder;

/**
 * Added in version 6.3.0
 *
 * Adds viewfinder.
 */
- (void)addViewfinder:(nonnull id<SDCViewfinder>)viewfinder;
/**
 * Added in version 6.3.0
 *
 * Removes all contained viewfinders.
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
