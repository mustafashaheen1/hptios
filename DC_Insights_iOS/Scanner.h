//
//  Scanner.h
//  i-nigmaSdkTest
//
//  Created by 1 on 12/28/09.
//  Copyright 2009 1. All rights reserved.
//

#include "i_nigma_sdk.h"
#ifdef __cplusplus
extern "C" {
#endif

void WrapError(void* pThis,const char* str);
void WrapNotify(void* pThis,const char* str);
void WrapDecode(void* pThis,const unsigned short* str,const char*  SymbolType,const char*  SymbolMode);
void WrapCameraStopOrStart(int on,void* pThis);

class CScanner : public SmartcodeDecoder::Observer {
public:
	CScanner(void* pControler);
	virtual ~CScanner();
	virtual void OnTimeout();						//Called if no bar code decoded till timeout occurred
	virtual void OnError(ErrorType error) ;		// Called on error
	virtual void OnNotification(NotificationType notification);		// Called on Notification
	virtual void OnDecode(unsigned char *result,int len,SmartcodeDecoder::DecodingFlags SymbolType,SmartcodeDecoder::DecodingMode mode);	// Called on successful decoding with the bar code content
	virtual void OnCameraStopOrStart(int on);	// Called after camera begin or stop to be able to add or remove GUI layers`
    void SetOrientation(long Orientation);
    void Scan(void* pView);
	//void Scan(void* pView,int x, int y, int w , int h ,int timeoutInSeconds = 45);
    // one more preview rect set for landscape
	void Scan(void* pView, int x, int y, int w, int h, int xLand, int yLand, int wLand, int hLand,
              int frontCamera, int justPreview, int timeoutInSeconds = 45);
    void StartDecoding();
	void UpdateLicense();
	void Abort();
	void CloseCamera();
    int IsTorchAvailable();
    void TurnTorch(int on);
    void OnBackground();
    void OnForground();

    bool isScanOut;
    bool onlyScanQR;

    bool isCodeExplorer;
    
private:
	void* m_pControler;
	SmartcodeDecoder* m_pDecoder;
    void* m_pView;
    int m_x;
    int m_y;
    int m_w;
    int m_h;
    int m_xLand;
    int m_yLand;
    int m_wLand;
    int m_hLand;
    int m_timeoutInSeconds;
    bool m_scan;
}; 
#ifdef __cplusplus
}
#endif


//@interface Scanner : Observer {

//}

//@end
