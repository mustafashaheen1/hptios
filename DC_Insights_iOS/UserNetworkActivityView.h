//
//  UserNetworkActivityView.h
//  shopwell
//
//  Created by Maurice Sharp on 12/14/11.
//  Copyright (c) 2011 ShopWell Solutions, Inc. All rights reserved.
//

// @TODO: Need to set the currentOperation instance variable appropriately
/*------------------------------------------------------------------------------
 CLASS: UserNetworkActivityView
 
 PURPOSE:
 A view to show the App is busy during user initiated network activity. The view
 shows the App is doing something by showing the Activity indictator inside the
 ShopWell logo. It also gives feedback if the network operation needs to retry.
 
 Finally, it enables the user to Cancel the operation in progress.
 
 Since there can only be one of these views active at any time, the object is
 implemented as a Singleton.
 
 IMPORTANT - the activity view is added as a subview of either the 
 UIViewController that called show:, or the view specied in the show:inView:
 call. If using show:inView: any views on top of inView will be on top of the
 feedback view.
 
 
 METHODS:
 + (UserNetworkActivityView*) sharedActivityView
		returns the singleton object
 
 - (void) show:(id <UserNetworkActivityViewProtocol>)theDelegate
	    inView:(UIView*)theView
 withOperation:(id)operation 
	showCancel:(BOOL)cancel
 
		Fill theView with the activity view for the given operation. operation
		should be a subclass of RetryingHTTPOperation, QHTTPOperation or
		SWBaseDataItem.
 
 - (void) show:(id <UserNetworkActivityViewProtocol>)theDelegate
 withOperation:(id)operation
	showCancel:(BOOL)cancel 
		Fill the delegates view with an alpha view and show the activity
		view in the center of that alpha view for the given operation.
		operation should be a subclass of RetryingHTTPOperation, QHTTPOperation,
		or SWBaseDataItem.

 
 - (BOOL) hidden
		Returns YES if the activity view is already hidden, NO otherwise
 
 - (void) hide
		hide the view and stop the activity indicator
 
 - (void) setCustomMessage:(NSString*)customMessage
		sets a custom message instead of "Looking up product"
 
 ACCESSORS:
 delegate
		The current delegate showing the activity view
  
 NOTES:
 
 
 -----------------------------------------------------------------------------*/



#import <UIKit/UIKit.h>


#define kUNAVDefaultMessage		@"Looking up product"

#define kUNAVNIBName			@"UserNetworkActivityView"


// forward declarations
@protocol  UserNetworkActivityViewProtocol ;



@interface UserNetworkActivityView : UIView
{
	id										currentOperation ;
	id <UserNetworkActivityViewProtocol>	delegate ;	
}


@property (strong, nonatomic) id currentOperation ;
@property (strong, nonatomic) id <UserNetworkActivityViewProtocol> delegate ;

+ (UserNetworkActivityView*) sharedActivityView ;

- (void) show:(id <UserNetworkActivityViewProtocol>)theDelegate
withOperation:(id)operation
   showCancel:(BOOL)cancel;

- (BOOL) hidden ;

- (void) hide ;

- (void) setCustomMessage:(NSString*)customMessage ;


- (IBAction)cancelTouched;

@end
