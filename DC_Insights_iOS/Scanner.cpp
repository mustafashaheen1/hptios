
//
//  Scanner.mm
//  i-nigmaSdkTest
//
//  Created by 1 on 12/28/09.
//  Copyright 2009 1. All rights reserved.
//

#include "Scanner.h"


CScanner::CScanner(void* pControler)
{
	m_pControler = pControler;
	m_pDecoder = SmartcodeDecoder::Load(this);
    m_scan=false;
}
CScanner::~CScanner()
{
   m_pDecoder->CloseCamera();
   delete m_pDecoder;
}
void CScanner::OnTimeout()
{
    m_scan=false;
	WrapError(m_pControler,"Time Out");

}
void CScanner::OnError(ErrorType error) 
{
    m_scan=false;
	switch (error) {
		case CameraInUseError:
			WrapError(m_pControler,"Camera in use Error");
			break;
		case GeneralError:
			WrapError(m_pControler,"General Error");
			break;
		case LicenseError:
			WrapError(m_pControler,"License Error");
			break;
		case CodeInvalidError:
			WrapError(m_pControler,"Code Invalid Error");
			break;
		case CodeNotSupportedError:
			WrapError(m_pControler,"Code Not Supported Error");
			break;
		default:
			break;
	} 
}
void CScanner::OnNotification(NotificationType notification){
	switch (notification) {
		case GettingLicenseStarted:
			WrapNotify(m_pControler, "Getting License Started");
			break;
		case LicenseProcessSucceeded:
			WrapNotify(m_pControler, "Getting License Succeeded");
			break;
		case LicenseProcessFailed:
			WrapNotify(m_pControler, "License Process Failed");
			break;
		case CameraStarted:
			WrapNotify(m_pControler, "Camera Started");
			break;
		case CameraClosed:
			WrapNotify(m_pControler, "Camera Closed");
			break;
		case CodeFound:
			WrapNotify(m_pControler, "Code Found");
			break;
        default:
			break;
	}	
}
void CScanner::OnDecode(unsigned char *result,int len,SmartcodeDecoder::DecodingFlags SymbolType,SmartcodeDecoder::DecodingMode SymbolMode)
{
    m_scan=true;
	// convert raw data to unicode string 
	unsigned short* str = new unsigned short[len+1]; 
	for (int i = 0 ; i < len; i++){
		str[i] = result[i];
	}
	str[len] = 0;
    const char* type;
    switch (SymbolType) {
        case SmartcodeDecoder::DecodeEAN8:
            type="EAN 8";
            break;
        case SmartcodeDecoder::DecodeEAN13:
            type="EAN 13";
            break;
        case SmartcodeDecoder::DecodeDataMatrix:
            type="Data Matrix";
            break;
        case SmartcodeDecoder::DecodeQR:
            type="QR Code";
            break;
        case SmartcodeDecoder::DecodePDF417:
            type="PDF 417";
            break;
        case SmartcodeDecoder::DecodeEAN128:
            type="Code 128";
            break;
        case SmartcodeDecoder::DecodeEAN39:
            type="Code 39";
            break;
        case SmartcodeDecoder::DecodeMicroQR:
            type="Micro QR";
            break;
        case SmartcodeDecoder::DecodeGS1_OMNI:
            type="GS1 OMNI";
            break;
        case SmartcodeDecoder::DecodeCODABAR:
            type="CODABAR NW7";
            break;
        case SmartcodeDecoder::Decode_2_of_5:
            type="2 of 5";
            break;
        default:
            type="";
            break;
    }
    const char* mode;
    switch (SymbolMode) {
        case SmartcodeDecoder::Func1:
            mode="FUNC1";
            break;
        case SmartcodeDecoder::Func2:
            mode="FUNC2";
            break;
        default:
            mode=0;
            break;
    }
    WrapDecode(m_pControler,str,type,mode);
    delete [] str;
}

void CScanner::OnCameraStopOrStart(int on) 
{
	WrapCameraStopOrStart(on,m_pControler);
}
void CScanner::Scan(void* pView)
{
    Scan(pView,5,5,300,400,
               5,5,500,500, 0,0);
}
/*void CScanner::Scan(void* pView,int x, int y, int w , int h ,int timeoutInSeconds)
{
    Scan(pView,x,y,w,h,x,y,w,h,timeoutInSeconds);
}
*/
void CScanner::Scan(void* pView,int x, int y, int w, int h,
                            int xLand, int yLand, int wLand, int hLand,
                            int frontCamera, int justPreview, int timeoutInSeconds)
{
    m_pDecoder->SetParameters(SmartcodeDecoder::TWO_OF_5_MIN_CODELENGTH, 12);
	
    int nDecodeEAN8 = SmartcodeDecoder::DecodeEAN8; 
	int nDecodeEAN13 = SmartcodeDecoder::DecodeEAN13; 
	int nDecodeEAN128 = SmartcodeDecoder::DecodeEAN128; 
	int nDecodeMicroQR = SmartcodeDecoder::DecodeMicroQR;
	int nDecodeQR = SmartcodeDecoder::DecodeQR; 
	int nDecodeDataMatrix = SmartcodeDecoder::DecodeDataMatrix; 
	int nDecodeBlackOnWhite = SmartcodeDecoder::DecodeBlackOnWhite; 
	int nDecodePDF417 = SmartcodeDecoder::DecodePDF417; 
    int nDecode_2_of_5 = SmartcodeDecoder::Decode_2_of_5;
    int nDecode_GS1_Omni = SmartcodeDecoder::DecodeGS1_OMNI;
    int nDecode_Codabar = SmartcodeDecoder::DecodeCODABAR;
    int nJustPreview = SmartcodeDecoder::JustPreview;
	m_pView=pView;
    m_x=x;
    m_y=y;
    m_w=w;
    m_h=h;
    m_xLand=xLand;
    m_yLand=yLand;
    m_wLand=wLand;
    m_hLand=hLand;
    m_timeoutInSeconds=timeoutInSeconds;
    if(isScanOut || isCodeExplorer) {
	m_pDecoder->Scan(m_pView,
                     m_x,m_y,m_w,m_h,
                     m_xLand,m_yLand,m_wLand,m_hLand,
					 nDecodeQR |
					 nDecodeDataMatrix
                     | (justPreview ? nJustPreview : 0),
                     //SmartcodeDecoder::ContinuousDecode,
                     m_timeoutInSeconds,
                     frontCamera ? SmartcodeDecoder::FrontCamera : SmartcodeDecoder::RearCamera
					 );
    }else if(onlyScanQR){
        m_pDecoder->Scan(m_pView,
                         m_x,m_y,m_w,m_h,
                         m_xLand,m_yLand,m_wLand,m_hLand,
                         nDecodeMicroQR |
                         nDecodeQR
                         | (justPreview ? nJustPreview : 0),
                         //SmartcodeDecoder::ContinuousDecode,
                         m_timeoutInSeconds,
                         frontCamera ? SmartcodeDecoder::FrontCamera : SmartcodeDecoder::RearCamera
                         );
    }else {
    m_pDecoder->Scan(m_pView,
                     m_x,m_y,m_w,m_h,
                     m_xLand,m_yLand,m_wLand,m_hLand,
                     nDecodeEAN8|
                     nDecodeEAN13 |
                     nDecodeEAN128 |
                     nDecodeMicroQR |
                     nDecodeQR |
                     nDecodeDataMatrix|
                     nDecodeBlackOnWhite|
                     nDecodePDF417|
                     nDecode_2_of_5	|
                     nDecode_GS1_Omni|
                     nDecode_Codabar
                     | (justPreview ? nJustPreview : 0),
                     //SmartcodeDecoder::ContinuousDecode,
                     m_timeoutInSeconds,
                     frontCamera ? SmartcodeDecoder::FrontCamera : SmartcodeDecoder::RearCamera
                     );
    }

    m_scan=true;
}
void CScanner::StartDecoding()
{
    m_pDecoder->StartDecoding();
}

void CScanner::SetOrientation(long Orientation)
{
    m_pDecoder->SetOrientation(Orientation);
}
void CScanner::UpdateLicense()
{
	m_pDecoder->UpdateLicense();	
}
void CScanner::Abort()
{
    m_scan=false;
	m_pDecoder->Abort();
}
void CScanner::CloseCamera()
{
    m_scan=false;
	m_pDecoder->CloseCamera();
}
int CScanner::IsTorchAvailable()
{
    return m_pDecoder->IsTorchAvailable();
}
void CScanner::TurnTorch(int on)
{
    m_pDecoder->TurnTorch(on);
}
void CScanner::OnBackground()
{
	m_pDecoder->Abort();
}
void CScanner::OnForground()
{
    if (m_scan)
        m_pDecoder->Scan(m_pView,m_x,m_y,m_w,m_h,SmartcodeDecoder::DecodeQR,m_timeoutInSeconds);
}


