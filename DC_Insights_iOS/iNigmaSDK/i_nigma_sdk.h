/*
 ============================================================================
 Name		: i_nigma_sdk.h
 Author	  : Adi Gadish
 Copyright   : Copyright 2009
 3GVision Ltd.
 Description : i_nigma_sdk.h - SmartcodeDecoder class header
 ============================================================================
 */

// This file defines the API for i_nigma_sdk.dll

#ifndef __I_NIGMA_SDK_H__
#define __I_NIGMA_SDK_H__

/*
* SmartcodeDecoder
*
* This is the abstract class for barcode decoder software, implemented for Windows Mobile 6 HTC devices.
*  
* Use the Construct function to create an instance of the decoder, then by using the Start/Stop functions you
* can control decoding.  Decoding information or other notifications (timeout, error etc) will be delivered
* to the observer.
* While scanning, the decoder will take over the device's camera, display & keypad, and scan for bar codes.
* The decoder will show the preview on the screen until a bar code was decoded, or timeout. The decoder will 
* prevent other applications using the camera as long as scanning is taking place.  On beginning auto focus 
* process will take place.  The user can also trigger auto focus by pressing the center key.  Also, the user
* can increase/decrease zoom by pressing the up/down keys.  After 45 seconds, timeout will occur if no bar 
* code decoded.
*
* Use this header file (i_nigma_sdk.h) in your application inc directory
* Link against the static library file (i_nigma_sdk.lib).
*
*/
struct SmartcodeDecoder
{

	enum DecodingFlags
	{
		None					= 0x00000000,	//No flags
		DecodeEAN8				= 0x00000001,	//Decode EAN8
		DecodeEAN13				= 0x00000002,	//Decode EAN13
		DecodeCODABAR			= 0x00000008,	//Decode Codabar NW7
        DecodeMicroQR           = 0x00000080,   //Decode Micro QR
        DecodeDataMatrix		= 0x00000100,	//Decode DataMatrix
		DecodeQR				= 0x00000200,	//Decode QR
		DecodePDF417			= 0x00000800,	//Decode PDF417
		DecodeEAN128			= 0x00001000,	//Decode Code 128
		DecodeEAN39				= 0x00002000,	//Decode Code 39
		Decode_2_of_5			= 0x00004000,	//Decode 2 of 5
        DecodeGS1_OMNI			= 0x00008000,   //Decode GS1 OMNI
        
		DecodeBlackOnWhite		= 0x00010000,	//Reverse B&W barcodes

		ContinuousDecode		= 0x10000000,	//Continuous decoding

        JustPreview             = 0x20000000,   //Only show camera preview.
                                                //StartDecoding() will be called separately to start analyzing frames
	};
    
	enum DecodingMode
	{
		NoFunc                  = 0x00000000,	//No func
		Func1                   = 0x00000001,	//Func1
		Func2                   = 0x00000002,	//Func2
	};
    
    enum CameraSelection
    {
        DefaultCamera           = 0x0001,       // Default is Rear Camera
        
        RearCamera              = 0x0001,       // The camera on the opposite side of the screen
        FrontCamera             = 0x0002,       // The camera that faces the user
    };
    
    //Observer
	//The application should inherit this class and implement its API
	struct Observer
	{
		virtual void OnTimeout()=0;						//Called if no bar code decoded till timeout occurred
		enum ErrorType
		{
			EmptyError=0,
			CameraInUseError,		// Camera could not be operated because it is used by other application
			GeneralError,			// Could not open the camera / Unknown error occurred
			LicenseError,			// No License / Wrong license / Insufficient license
			CodeInvalidError,
			CodeNotSupportedError
		};
		virtual void OnError(ErrorType error) = 0;		// Called on error
		enum NotificationType
		{
			EmptyNofitication = 0,
			GettingLicenseStarted,
			LicenseProcessSucceeded,
			LicenseProcessFailed,
			CameraStarted,
			CameraClosed,
			CodeFound
		};
		virtual void OnNotification(NotificationType notification) = 0;		// Called on Notification
		virtual void OnDecode(unsigned char* res,int len,DecodingFlags SymbolType,DecodingMode mode) = 0;	// Called on successful decoding with the bar code content
		virtual void OnCameraStopOrStart(int on) {}	// Called on camera view begin or stop 
	};

	//New
	//Application should create an instance of SmartcodeDecoder by calling this function.
	//project is your project id assigned by 3GVision
	//observer points to the Application Observer so notification and results can be indicated
	static SmartcodeDecoder* New(Observer* observer);
	virtual ~SmartcodeDecoder();

	
	//Scan
	//Application should call this function in order to start scanning
	virtual void Scan(void* pUIView,
					  int PrevX,
					  int prevY,
					  int PrevW,
					  int PrevH,
					  int flags,
					  int timeoutInSeconds = 45,
                      CameraSelection whichCamera = DefaultCamera) = 0;

	//Scan
	//Application could call this function in order to start scanning
    // with option to set the previrew rect on portrait and landscape
	virtual void Scan(void* pUIView,
					  int PrevXportrait,
					  int prevYportrait,
					  int PrevWportrait,
					  int PrevHportrait,
					  int PrevXlandscape,
					  int prevYlandscape,
					  int PrevWlandscape,
					  int PrevHlandscape,
					  int flags,
					  int timeoutInSeconds = 45,
                      CameraSelection whichCamera = DefaultCamera) = 0;

    //StartDecoding
    //If Scan flags included JustPreview, this function will start analyzing frames for barcodes. No effect otherwise
    virtual void StartDecoding() = 0;
    
	//StartAutoFocus
	//Application should call this function in order to start auto focus process
	virtual void StartAutoFocus() = 0;

	//Abort
	//Application should call this function in order to stop scanning and hide camera
	virtual void Abort() = 0;
	
	//CloseCamera
	//Application should call this function in order to close camera and able to open it on different view
	virtual void CloseCamera() = 0;

	//UpdateLicense
	//Application should call this function if a non scheduled license update is required.
	virtual void UpdateLicense() = 0;

    // Torch functions: 
    // IsTorchAvailable 
    // Return 1 if device has torch (flashlight)
    virtual int IsTorchAvailable()=0;
    
    // TurnTorch 
    // Turn torch on and off)
    virtual void TurnTorch(int on)=0;

    // SetOrientation 
    // Set camera orientation
    virtual void SetOrientation(long orientationint)=0;

	//Version
	//Returns the version of the decoder.
	virtual int Version();
    
 	enum ScanParameters
	{
		TWO_OF_5_CHECKSUM_DIGIT	= 0x00000010,// Set 1 for check sum , default value is 0
		TWO_OF_5_MIN_CODELENGTH	= 0x00000011,// Set Min code length or 0 for unlimited ,  default value is 0
		TWO_OF_5_MAX_CODELENGTH	= 0x00000012 // Set Max code length or 0 for unlimited ,  default value is 0
    };
 
	//SetParameters
	//Set Parameter to scanner.
	virtual void SetParameters(ScanParameters param , int val)=0;
  
protected:
	SmartcodeDecoder();

public:
	//Load
	//Application can use this function in order to create an instance of SmartcodeDecoder.
	//The function loads the dll and calls the factory method "New"
	static inline SmartcodeDecoder* Load(Observer* observer)
	{
		return SmartcodeDecoder::New(observer);
	}

};




#endif  // __I_NIGMA_SDK_H__

