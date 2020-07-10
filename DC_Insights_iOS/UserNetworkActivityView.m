//
//  UserNetworkActivityView.m
//  shopwell
//
//  Created by Maurice Sharp on 12/14/11.
//  Copyright (c) 2011 ShopWell Solutions, Inc. All rights reserved.
//

#import "UserNetworkActivityView.h"
#import "UserNetworkActivityViewProtocol.h"


// Private class declarations

@interface UserNetworkActivityView ()
{
	CGFloat			screenYOffset;
}


@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *retryLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@end


static UserNetworkActivityView *_sharedUserNetworkActivityView = nil; 

// destroys sharedInstance after main exits.. REQUIRED for unit tests
// to work correclty, otherwse the FIRST shared object gets used for ALL
// tests, resulting in KVO problems
__attribute__((destructor)) static void destroy_singleton() {
	@autoreleasepool {
		_sharedUserNetworkActivityView = nil;
	}
}

@implementation UserNetworkActivityView

@synthesize backgroundView;
@synthesize currentOperation ;
@synthesize delegate ;
@synthesize cancelButton;
@synthesize mainView;
@synthesize messageLabel;
@synthesize retryLabel;
@synthesize activityView;


#pragma mark - Class Access Method

/*------------------------------------------------------------------------------
 METHOD: sharedActivityView
 
 PURPOSE:
 Gets the shared network activity view instance object and creates it if
 necessary.
 
 RETURN VALUE:
 The shared network activity view.
 
 -----------------------------------------------------------------------------*/
+ (UserNetworkActivityView*) sharedActivityView
{
	if (_sharedUserNetworkActivityView == nil)
		[UserNetworkActivityView initialize] ;
	
	return _sharedUserNetworkActivityView ;
}



#pragma mark - Initialization

/*------------------------------------------------------------------------------
 METHOD: initWithFrame:
 
 PURPOSE:
 Specialize the method to load in the view from the NIB.
 
 RETURN VALUE:
 The initialized view
 
 NOTE:
 The return value from the loadNibNamed:owner:options: call is not needed. Just
 calling the method will cause the NIB to load and set all the accessors that
 are assigned in the xib file.
 
 -----------------------------------------------------------------------------*/
- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[[NSBundle mainBundle] loadNibNamed:kUNAVNIBName owner:self options:nil];
        
        self.messageLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        self.retryLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
	
		screenYOffset = [UIScreen mainScreen].bounds.size.height - 480.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            screenYOffset = [UIScreen mainScreen].bounds.size.height;// - 480.0;
        }
        //make it use full screen
		UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        CGRect newFrame = CGRectMake(0, 0, win.frame.size.width, backgroundView.frame.size.height); //backgroundView.frame;
        
        //self.frame = CGRectMake(0, -20, win.frame.size.width, win.frame.size.height);
        //[activityView setFrame:CGRectMake(0, 0, win.frame.size.width, win.frame.size.height)];
		
		newFrame.size.height += screenYOffset;
		backgroundView.frame = newFrame;

		newFrame = mainView.frame;
		newFrame.origin.y += screenYOffset;
		
		mainView.frame = newFrame;
	}
	
	return self ;
}



#pragma mark - View Show/Hide Messages

/*------------------------------------------------------------------------------
 METHOD: show:inView:withOperation:showCancel:
 
 PURPOSE:
 Show the network activity view and start the activity indicator animating, and
 set the delegate. The call takes the view controller for adding the activity
 view.
 
 -----------------------------------------------------------------------------*/
- (void) show:(id <UserNetworkActivityViewProtocol>)theDelegate
withOperation:(id)operation
   showCancel:(BOOL)cancel
{
	UIView	*theView = [[UIApplication sharedApplication] keyWindow];
	
	self.currentOperation = operation ;
	
	// set the delegate
	self.delegate = theDelegate ;
	
	
	cancelButton.hidden = !cancel ;

	backgroundView.hidden = NO ;
	
	[theView addSubview:backgroundView] ;

	// position the view appropriately
	CGFloat xLeft, yTop ;
	
	xLeft = backgroundView.frame.origin.x +
		((backgroundView.frame.size.width - mainView.bounds.size.width) / 2) ;
	yTop = backgroundView.frame.origin.y +
		((backgroundView.frame.size.height - mainView.bounds.size.height) / 2) ;
	
	// need to add 40.0 because the status bar will be drawn on top of the
	// activity view even though it is full screen
	mainView.frame = CGRectMake(xLeft, yTop + 40.0, mainView.bounds.size.width, mainView.bounds.size.height) ;
	
	[theView addSubview:mainView] ;
	
	self.activityView.hidden = NO ;
	[activityView startAnimating] ;
}



/*------------------------------------------------------------------------------
 METHOD: hidden
 
 PURPOSE:
 Find out if the activty view is currently hidden
 
 RETURN VALUE:
 YES if the view is hidden, otherwise NO
 -----------------------------------------------------------------------------*/
- (BOOL)hidden
{
	return backgroundView.hidden ;
}


/*------------------------------------------------------------------------------
 METHOD: hide
 
 PURPOSE:
 Hides the network activity view and stops the activity indicator animating. It
 also resets the message to the default message.

 -----------------------------------------------------------------------------*/
- (void) hide
{
	if (!backgroundView.hidden) {
		
		self.currentOperation = nil ;
		
		self.activityView.hidden = YES ;
		[activityView stopAnimating] ;
		
		[mainView removeFromSuperview] ;
		[backgroundView removeFromSuperview] ;
		
		self.delegate = nil ;
		
		backgroundView.hidden = YES ;
		self.messageLabel.text = kUNAVDefaultMessage ;
	}
}



#pragma mark - KVO Message

/*------------------------------------------------------------------------------
 METHOD: observeValueForKeyPath:ofObject:change:context:
 
 PURPOSE:
 KVO callback method. Used to detect if the network operation is retrying.
 
 -----------------------------------------------------------------------------*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#pragma unused (context)
	
	if ([keyPath isEqual:@"hasHadRetryableFailure"]) {
		assert([NSThread isMainThread]);
		
		if ((self.mainView.hidden == NO)) {
			
			[UIView beginAnimations:nil context:nil] ;
			
			[UIView setAnimationBeginsFromCurrentState:YES] ;
			[UIView setAnimationDelay:0.2] ;
			
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
								   forView:retryLabel
									 cache:NO] ;
			
			retryLabel.hidden = NO ;
			
			[UIView commitAnimations] ;
		}
	}
}



#pragma mark - Public Messages

/*------------------------------------------------------------------------------
 METHOD: setCustomMessage:
 
 PURPOSE:
 Changes the default message shown in the activity view to a custom message.
 Does check that the argument is a valid string, though not if it is an empty
 string.
 
 -----------------------------------------------------------------------------*/
- (void) setCustomMessage:(NSString*)customMessage
{
	if (customMessage && [customMessage isKindOfClass:[NSString class]]) {
		self.messageLabel.text = customMessage ;
	}
}



#pragma mark - User Interface Element Messages

/*------------------------------------------------------------------------------
 METHOD: cancelTouched
 
 PURPOSE:
 Handle the user touching the Cancel button. Cancel any in progress network
 operation and inform the delegate the user cancelled.
 
 -----------------------------------------------------------------------------*/
- (IBAction)cancelTouched
{
	if (delegate != nil)
		[(NSObject*)delegate performSelector:@selector(userCancelledOperation)] ;
	
	[self hide] ;
}



/*------------------------------------------------------------------------------
 Singleton Methods.. Generic to any Singleton
 -----------------------------------------------------------------------------*/
#pragma mark - Singleton Methods

+ (void)initialize
{
    if (_sharedUserNetworkActivityView == nil)
        _sharedUserNetworkActivityView = [[self alloc] init];
}


+ (id)sharedUserNetworkActivityView
{
    //Already set by +initialize.
    return _sharedUserNetworkActivityView;
}


+ (id)allocWithZone:(NSZone*)zone
{
    //Usually already set by +initialize.
    if (_sharedUserNetworkActivityView) {
        //The caller expects to receive a new object, so implicitly retain it
        //to balance out the eventual release message.
        return _sharedUserNetworkActivityView;
    } else {
        //When not already set, +initialize is our caller.
        //It's creating the shared instance, let this go through.
        return [super allocWithZone:zone];
    }
}


- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

@end
