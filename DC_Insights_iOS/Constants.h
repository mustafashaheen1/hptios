//
//  Constants.h
//	global constants.
//

// Version contants
#define IS_IPHONE6S (([[UIScreen mainScreen] bounds].size.height-736)?NO:YES)
#define IS_IPHONE6 (([[UIScreen mainScreen] bounds].size.height-667)?NO:YES)
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_IPHONE4 (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

// Networking Operations
#define maximumConcurrentOperations 5

//URLS

//#define endPointURL @"http://192.168.15.179/"
#define endPointURL_AWS                                     @"http://ec2-52-26-87-142.us-west-2.compute.amazonaws.com/"
#define endPointURL_PROD                                    @"https://portal.harvestmark.com/"

#define endPointURL_QA_AZURE                                @"https://qa.harvestmark.com/"

#define loginURL                                            @"api/tokens"
#define Audits                                              @"api/audits"
#define googleLoginURL                                      @"google_auth"
#define Containers                                          @"api/containers"
#define ContainersRatings                                   @"api/containers/ratings"
#define DefectsFamilies                                     @"api/defect_families"
#define Defects                                             @"api/defects"
#define Programs                                            @"api/programs"
#define InspectionMinimum                                  @"api/inspection_minimums"
#define ProgramsProducts                                    @"api/programs/products"
#define ProgramsGroups                                      @"api/programs/groups"
#define Ratings                                             @"api/ratings"
#define Stores                                              @"api/stores"
#define Locations                                           @"api/ratings/locations"
#define DeletionLog                                         @"api/insights_deletion_logs"
#define OrderDatas                                          @"api/order_data"
#define InspectionStatuses                                  @"api/inspection_statuses"
#define Containers                                          @"api/containers"
#define collobarativeInspectionsList                        @"api/inspections/list"
#define collobarativeInspectionsSave                        @"api/inspections/save"
#define StoresLocations                                     @"api/stores/location"
#define Sync                                                @"api/sync"
#define Log                                                 @"api/log"
#define ImageHost                                           @"api/audits/imageHost"
#define endPoint_PortalHeartbeat                            @"https://portal.harvestmark.com/tesco.json"
#define ReachabilityHost                                    @"www.google.com"
#define ReachabilityHostDCInsightsQA5                       @"qa5rorportal.yottamark.local"
#define ReachabilityHostDCInsightsPROD                      @"portal.harvestmark.com"

//Filepaths

#define loginFilePath                                       @"login.json"
#define storesFilePath                                      @"stores.json"
#define locationsFilePath                                   @"locations.json"
#define orderDataFilePath                                   @"orderData"
#define storesLocationFilePath                              @"storesLocation.json"
#define containerFilePath                                   @"container.json"
#define containerRatingsFilePath                            @"containerRatings.json"
#define defectsFilePath                                     @"defects.json"
#define defectsFamiliesFilePath                             @"defectsFamilies.json"
#define ProgramsFilePath                                    @"Programs.json"
#define DeletionLogsPath                                    @"DeletionLogsApi.json"
#define ProgramsProductsFilePath                            @"ProgramsProducts.json"
#define ProgramsGroupsFilePath                              @"ProgramsGroups.json"
#define RatingsFilePath                                     @"ratings.json"
#define InspectionMinimumsFilePath                          @"InspectionMinimums.json"


// NSUserDefaults keys

#define ACCESS_TOKEN                                        @"token"
#define UPDATE_METHOD                                       @"update_method"
#define DEVICE_ENABLED                                      @"enabled"
#define DEVICE_ID                                           @"device_id"
#define EMAIL                                               @"email"
#define PASSWORD                                            @"password"
#define LASTSYNCDATE                                        @"lastSyncDate"
#define IMAGE_HOST_ENDPOINT                                 @"imageHostEndpoint"
#define PORTAL_ENDPOINT                                     @"portalEndpoint"
#define AUDITOR_ROLE                                        @"auditor_role"
#define StoreEnteredByUser                                  @"StoreEnteredByUser"
#define StoreNameEnteredByUser                              @"StoreNameEnteredByUser"
#define StoreAddressEnteredByUser                           @"StoreAddressEnteredByUser"
#define StoreZipCodeEnteredByUser                           @"StoreZipCodeEnteredByUser"
#define UPDATEMETHOD                                        @"UPDATEMETHOD"
#define ORDER_DATA_PRESENT                                  @"ORDER_DATA_PRESENT"
#define CE_HISTORY_ARRAY                                    @"CE_HISTORY_ARRAY"
#define UPLOADS_LOGS                                        @"UPLOADS_LOGS"
#define CRASH_LOGS                                          @"CRASH_LOGS"
#define PENDING_UPLOAD_REQUESTS                             @"PENDING_UPLOAD_REQUESTS"
#define BACKGROUND_UPLOAD_ENABLED                           @"BACKGROUND_UPLOAD_ENABLED"
#define CAMERA_FLASH_SETTING                                @"CAMERA_FLASH_SETTING"
#define INSPECTION_TYPE                                     @"inspectionType"

//User
#define DEVICE_ID                                           @"device_id"
#define LAST_SYNC_TIME                                      @"last_sync_time"
#define SOFTWARE_VERSION                                    @"current_software_version"
#define EMAIL                                               @"email"
#define PASSWORD                                            @"password"
#define AUWS                                                @"get_auws_token"
#define GPS                                                 @"GPSAvailable"
#define NOGPS                                               @"GPSUnAvailable"


//RatingsTableView
#define kEmptyTableCellIdentifier                           @"EmptyTableCell"

#define TEXT_RATING                                         @"TextRating"
#define DATE_RATING                                         @"DateRating"
#define NUMERIC_RATING                                      @"NumericRating"
#define PRICE_RATING                                        @"PriceRating"
#define COMBO_BOX_RATING                                    @"ComboboxRating"
#define LOCATION_RATING                                    @"LocationsRating"
#define BOOLEAN_RATING                                      @"BooleanRating"
#define STAR_RATING                                         @"StarRating"
#define LABEL_RATING                                        @"LabelRating"

// Ratings
#define Units                                               @"Units"
#define OUTOFBOUNDS                                         @"NA"
#define PONUMBER_DICT                                       @"poNumber"
#define GRN_DICT                                       @"grn"
#define OTHER_DICT                                          @"otherDict"
#define DATETIME_DICT                                       @"DATETIME_DICT"
#define VENDORNAME_DICT                                     @"VENDORNAME_DICT"

//misc
#define CONST_TRUE                                          @"TRUE"
#define CONST_FALSE                                         @"FALSE"
#define SelectedProgramId                                   @"SelectedProgramId"
#define SelectedProgramVersion                              @"SelectedProgramVersion"

//ParentNavigation

#define ALBUMNAME                                           @"DCInsights"
#define SYNCSUCCESS                                         @"SYNCSUCCESS"
#define DEFAULT_IMAGE_HOST                                  @"http://cdn.yottamark.com/portal/_qa/audits" //needs prod url
#define DEFAULT_PORTAL_ENDPOINT                             @"https://qa.harvestmark.com/"

//Initialization For Flow

#define STOREID                                             @"StoreId"
#define STORE_NAME                                          @"StoreName"
#define LatitudeForTheEntireApp                             @"LatitudeForTheEntireApp"
#define LongitudeForTheEntireApp                            @"LongitudeForTheEntireApp"
#define LongitudeForTheEntireApp                            @"LongitudeForTheEntireApp"

//#define RATING_FOR_AVERAGE_COUNT = @"COUNT OF CASES";


//Settings

#define SyncOverWifi                                        @"SyncOverWifi"
#define SyncOverWifiButtonSet                               @"SyncOverWifiButtonSet"
#define SyncDownloadTime                                    @"SyncDownloadTime"
#define SyncUploadTime                                      @"SyncUploadTime"
#define SyncOrderDataDownloadTime                           @"SyncOrderDataDownloadTime"
#define SyncSuccessfulAlert                                 @"Sync Successful"
#define LastDownloadSync                                    @"Last Download Sync"
#define LastUploadSync                                      @"Last Upload Sync"
#define LastOrderDataDownloadSync                           @"Last Order Data Download Sync"
#define colloborativeInspectionsEnabled                     @"colloboartiveInspectionsEnabled"
#define enableIncrementalSync                               @"enableIncrementalSync"
#define enableBackgroundUploads                             @"enableBackgroundUploads"

//Login

#define usernameForLogoutSaved                              @"usernameForLogoutSaved"

//Loading

#define SavingAudits                                        @"Saving Data...."
#define PreparingRatings                                    @"Preparing Ratings"
#define SavingContainerRatings                              @"Saving Data...."
#define CreatingDuplicateAudits                             @"Creating Duplicates.."
#define PreparingDuplicateAudits                            @"Preparing For Duplicates.."

//Popup Box
#define popupDefaultHeight (([[UIScreen mainScreen] bounds].size.height-568)?430.0f:520.0f)
#define popupDefaultHeightDates 200.0f

//Current Audit
#define introducingDelayForDuplicates 0.005
#define tableViewAnimate 2
//Order Data Fields
#define introducingDelayForDBCalls 0.05
#define ORDERDATACARRIERNAME @"CARRIERNAME"
#define ORDERDATADCNAME @"DCNAME"
#define ORDERDATAEXPECTEDDELIVERYDATETIME @"EXPECTEDDELIVERYDATETIME"
#define ORDERDATAITEMNAME @"ITEMNAME"
#define ORDERDATAITEMNUMBER @"ITEMNUMBER"
#define ORDERDATAPOLINENUMBER @"POLINENUMBER"
#define ORDERDATAPOLINENUMBERVALUE @"POLINENUMBERVALUE"
#define ORDERDATAPONUMBER @"PONUMBER"
#define ORDERDATAGRN @"GRN"
#define ORDERDATAPROGRAMNAME @"PROGRAMNAME"
#define ORDERDATAQUANTITYOFCASES @"QUANTITYOFCASES"
#define ORDERDATARECEIVEDDATETIME @"RECEIVEDDATETIME"
#define ORDERDATAVENDORCODE @"VENDORCODE"
#define ORDERDATAVENDORNAME @"VENDORNAME"
#define ORDERDATALOADID @"LOADID"
#define ORDERDATACUSTOMERCODE @"CUSTOMERCODE"
#define ORDERDATACUSTOMERNAME @"CUSTOMERNAME"
/*
//OrderData Field Mapping in api/ratings
#define ORDERDATA_KEY_ID @"ID"
#define ORDERDATA_KEY_DCNAME @"DCName"
#define ORDERDATA_KEY_RECEIVEDDATETIME @"ReceivedDateTime"
#define ORDERDATA_KEY_EXPECTEDDELIVERYDATETIME @"ExpectedDeliveryDateTime"
#define ORDERDATA_KEY_PONUMBER @"PONumber"
#define ORDERDATA_KEY_GRN @"GRN"
#define ORDERDATA_KEY_POLINENUMBER @"POLineNumber"
#define ORDERDATA_KEY_ITEMNUMBER @"ItemNumber"
#define ORDERDATA_KEY_ITEMNAME @"ItemName"
#define ORDERDATA_KEY_VENDORCODE @"VendorCode"
#define ORDERDATA_KEY_VENDORNAME @"VendorName"
#define ORDERDATA_KEY_QUANTITYOFCASES @"QuantityOfCases"
#define ORDERDATA_KEY_POLINENUMBERVALUE @"POLineNumberValue"
#define ORDERDATA_KEY_CARRIERNAME @"CarrierName"
#define ORDERDATA_KEY_PROGRAMNAME @"ProgramName"
#define ORDERDATA_KEY_FLAGGEDPRODUCT @"FlaggedProduct"
#define ORDERDATA_KEY_FLAGGEDMESSAGES @"FlaggedMessages"
#define ORDERDATA_KEY_LOADID @"loadId"
*/
#define DAYSBEFORENUMBER @"daysBeforeNumber"
#define DAYSAFTERNUMBER @"daysAfterNumber"

#define OrderDataDefaultNumberOfDays @"0"
#define OrderDataLimitPerCall @"50"
#define OrderDataDateTimeSet @"OrderDataDateTimeSet"

//background upload
#define NOTIFICATION_BACKGROUND_UPLOAD_STARTED @"DCInsights_BackgroundUploadStarted"
#define NOTIFICATION_BACKGROUND_UPLOAD_COMPLETED @"DCInsights_BackgroundUploadComplete"
#define BACKGROUND_UPLOAD_TIME_INTERVAL 120

//Auditor Roles
#define AUDITOR_ROLE_RETAIL @"Retail Auditor"
#define AUDITOR_ROLE_DC @"DC Auditor"
#define AUDITOR_ROLE_SCANOUT @"ScanOut User"
#define AUDITOR_ROLE_CODEEXPLORER @"CodeExplorer User"
#define ALL_ROLES @"ALL_ROLES"

#define seventeenHours 61200000
#define imageSizeFromServer @"mobile400"

//Images
#define imageSizeFromServer @"mobile400"
/*!
 *  Program
 */
#define selectedProgramName @"ProgramNameSelected"
#define programIsDistinctSamplesMode @"programIsDistinctSamplesMode"
/*!
 *  Defect
 */

#define OtherDefectGroup @"Other"

#define finisingUp @"Finishing..."
#define defineContainerViewController @"ContainerViewController"
#define defineProductViewController @"ProductViewController"
#define defineApplyToAllViewController @"ApplyToAllViewController"
#define defineProductSelectViewController @"ProductSelectViewController"
#define defineInspectionStatusViewController @"InspectionStatusViewController"

#define countOfStoresForFetching 10

#define VendorNameSelected @"VendorNameSelected"
#define CustomerNameSelected @"CustomerNameSelected"
#define UpdateLink @"http://www.google.com"

//UpdateMethods
#define AutoUpdateMethod @"auto"
#define ForcedUpdateMethod @"force"
#define ManualUpdateMethod @"manual"

//Home
#define Uploading @"Uploading..."
#define InspectionsUploaded @"Audits Uploaded"
#define ScanoutsUploaded @"ScanOuts Uploaded"
#define noInspectionsToUpload @"There are no Audits available for upload"
#define AppID @"DCINSIGHTS_iOS"
#define LoadingContainersProducts @"Loading Containers and Products"
#define LoadingPalletShippingRating @"Loading Pallet Shipping Ratings"
#define LoadingOrderData @"Loading Order Data"

//ViewNames

#define kNibFileImageEditViewController @"ImageEditViewController"
#define kNibProductViewController @"ProductViewController"
#define kNibApplyToAllViewController @"ApplyToAllViewController"
#define kNibContainerViewController @"ContainerViewController"

//LogView
#define LOCATIONS_FILE @"Locations"
#define LOCATIONS_FILE_TYPE @"log"

//OrderData
#define QuantityOfCasesString @"QuantityOfCases"
#define OrderDataMinimumCount 0

//Distinct Samples
//#define distinctSamples [[[NSUserDefaultsManager getObjectFromUserDeafults:selectedProgramName] lowercaseString] isEqualToString:@"aldi"] || [[Inspection sharedInspection] checkForSysco]
#define aggregateSamplesMode ![NSUserDefaultsManager getBOOLFromUserDeafults:@"programIsDistinctSamplesMode"]


//PAgination
#define minimumNumberForCalls 5
#define limitPerPage 100
#define initialPageNo 0
#define RETRY_LIMIT 2

#define DEBUG_APP NO

//pagination
#define apiPaginationSize 50

//Container
#define containerIdForProductsFiltering       @"containerIdForProductsFiltering"

//Features
#define PAGINATE_SYNC_API YES
#define sendNotificationOptionEnabled YES
#define FILTER_PRODUCTS_CONTAINERS NO
#define OPTIMIZED_PAGINATED_SYNC YES

#define DEFAULT_STAR_RATING_ENABLED YES
//PArsing
#define parseIdentifier @"^^$$^^"

//Collaborative Inspections
#define STATUS_NOT_STARTED 0
#define STATUS_STARTED 1
#define STATUS_FINSIHED 2

#define ORDER_DATA_DOWNLOAD_FAILED 0
#define ORDER_DATA_DOWNLOAD_SUCCESS 1
#define ORDER_DATA_DOWNLOAD_EMPTY 2

#define COLLABORATIVE_LIST_RESPONSE @"COLLABORATIVE_LIST_RESPONSE"
#define COLLABORATIVE_BACKGROUND_UPLOAD_TIME_INTERVAL 30000 //5min
#define NOTIFICATION_COLLABORATIVE_CONNECTION_ERROR @"NOTIFICATION_COLLABORATIVE_CONNECTION_ERROR"

//CodeExplorer

#define CE_EVENT_NAME_ROW_HEIGHT 45
#define CE_EVENT_ATTRIBUTE_ROW_HEIGHT 70
#define CE_EVENT_ATTRIBUTE_VALUE_ROW_HEIGHT 25
#define CE_EVENT_ATTRIBUTE_LEFT_MARGIN 15
#define CE_EVENT_ATTRIBUTE_RIGHT_MARGIN 10
#define CE_EVENT_ATTRIBUTE_HEIGHT_BUFFER 20 

#define CE_TRACE_METHOD_SCANNED @"scanned"
#define CE_TRACE_METHOD_TYPED @"typed"
#define CE_TRACE_METHOD_HISTORY @"history"
#define SCAN_CANCELLED @"SCAN_CANCELLED"

#define BUTTON_CORNER_RADIUS 7
#define PROGRAM_ZESPRI NO //for Zespri


//Program Type
#define INVENTORY_PROGRAM_TYPE @"2"
#define INSIGHTS_PROGRAM_TYPE @"1"



