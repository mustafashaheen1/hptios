//
//  DBConstants.m
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 3/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import "DBConstants.h"

@implementation DBConstants

/* --- SQLITE Constants --- */

// Databases

NSString * const DB_APP_DATA = @"appData";
NSString * const DB_INSIGHTS_DATA = @"insightsData";
NSString * const DB_OFFLINE_DATA = @"offlineData";
NSString * const DB_ORDER_DATA = @"orderDataDB";

// Preferences
NSString * const PREF_AUDIT_MASTER_ID = @"AUDIT_MASTER_ID";
NSString * const PREF_CONTAINER_RATINGS = @"CONTAINER_RATINGS";
NSString * const PREF_INSPECTION_ACTIVE = @"INSPECTION_ACTIVE";
NSString * const AUTH_TOKEN = @"AUTH_TOKEN";
NSString * const LAST_SYNC_DATE = @"LAST_SYNC_DATE";
NSString * const LOGIN_CREDS = @"LOGIN_CREDS";
NSString * const USER_NAME = @"USER_NAME";

// SQLite Tables
NSString * const TBL_USERS = @"USERS";
NSString * const TBL_COMPLETED_AUDITS = @"COMPLETED_AUDITS";
NSString * const TBL_USER_ENTERED_STORES = @"USER_ENTERED_STORES";
NSString * const TBL_SAVED_AUDITS = @"SAVED_AUDITS";
NSString * const TBL_SAVED_CONTAINERS = @"SAVED_CONTAINERS";
NSString * const TBL_SAVED_SUMMARY = @"SAVED_SUMMARY";
NSString * const TBL_CONTAINERS = @"CONTAINERS";
NSString * const TBL_CONTAINER_RATINGS = @"CONTAINER_RATINGS";
NSString * const TBL_CONTAINER_RATING_CONDITIONS = @"CONTAINER_RATINGS_CONDITIONS";
NSString * const TBL_PROGRAMS = @"PROGRAMS";
NSString * const TBL_PRODUCTS = @"PRODUCTS";
NSString * const TBL_GROUP_RATINGS = @"GROUP_RATINGS";
NSString * const TBL_DEFECT_FAMILIES = @"DEFECT_FAMILIES";
NSString * const TBL_DEFECT_FAMILY_DEFECTS = @"DEFECT_FAMILY_DEFECTS";
NSString * const TBL_RATINGS = @"RATINGS";
NSString * const TBL_STORES = @"STORES";
NSString * const TBL_LOCATIONS = @"LOCATIONS";
NSString * const TBL_GROUPS = @"GROUPS";
NSString * const TBL_APP_LOGS = @"APP_LOGS";
NSString * const TBL_API_JSON = @"API_JSON";
NSString * const TBL_DEFECT_IMAGES = @"DEFECT_IMAGES";
NSString * const TBL_STAR_RATING_IMAGES = @"STAR_RATING_IMAGES";
NSString * const TBL_PRODUCT_QUALITY_MANUAL = @"QUALITY_MANUAL";
NSString * const TBL_INSPECTION_MINIMUMS = @"INSPECTION_MINIMUMS";
NSString * const TBL_ORDERDATA = @"ORDER_DATA";
NSString * const TBL_SUBMITTED_AUDITS = @"TBL_SUBMITTED_AUDITS";
NSString * const TBL_COLLABORATIVE_LOCAL_UPDATES = @"TBL_COLLABORATIVE_LOCAL_UPDATES";
NSString * const TBL_COLLABORATIVE_SAVE_REQUESTS = @"TBL_COLLABORATIVE_SAVE_REQUESTS";

// SQLite Columns
NSString * const COL_USERNAME = @"username";
NSString * const COL_PASSWORD = @"password";
NSString * const COL_AUDIT_DATA = @"AUDIT_DATA";
NSString * const COL_AUDIT_IMAGE = @"AUDIT_IMAGE";
NSString * const COL_DATA_SUBMITTED = @"DATA_SUBMITTED";
NSString * const COL_DATA_COMPLETED_TIME = @"DATA_COMPLETED_TIME";
NSString * const COL_DATA_SUBMITTED_TIME = @"DATA_SUBMITTED_TIME";
NSString * const COL_IMAGE_SUBMITTED = @"IMAGE_SUBMITTED";
NSString * const COL_ID = @"id";
NSString * const COL_NAME = @"name";
NSString * const COL_DISPLAY_NAME = @"display";
NSString * const COL_INSPECTION_MINIMUMS = @"INSPECTION_MINIMUMS";
NSString * const COL_INSPECTION_MINIMUMS_RATING_ID = @"INSPECTION_MINIMUMS_RATING_ID";
NSString * const COL_SPLIT_GROUP_ID = @"SPLIT_GROUP_ID";
NSString * const COL_NOTIFICATION_CHANGED = @"NOTIFICATION_CHANGED";
NSString * const COL_AUDIT_MASTER_ID = @"AUDIT_MASTER_ID";
NSString * const COL_AUDIT_GROUP_ID = @"AUDIT_GROUP_ID";
NSString * const COL_AUDIT_JSON = @"AUDIT_JSON";
NSString * const COL_AUDIT_PRODUCT_ID = @"AUDIT_PRODUCT_ID";
NSString * const COL_IMAGES = @"IMAGES";
NSString * const COL_INSP_STATUS = @"INSP_STATUS";
NSString * const COL_AUDITS_COMPLETED = @"AUDITS_COMPLETED";
NSString * const COL_PROGRAM_ID = @"program_id";
NSString * const COL_PRODUCT_ID = @"product_id";
NSString * const COL_PRODUCT_GROUP_ID = @"productGroup_id";
NSString * const COL_COUNT_OF_CASES = @"count_of_cases";
NSString * const COL_INSPECTION_COUNT_OF_CASES = @"inspection_count_of_cases";
NSString * const COL_PARENT_ID = @"parent_id";
NSString * const COL_PIC_REQUIRED = @"picture_required";
NSString * const COL_CONTAINER_ID = @"container_id";
NSString * const COL_DEFECT_FAMILY_ID = @"defect_family_id";
NSString * const COL_DEFECTS = @"defects";
NSString * const COL_ORDER_POSITION = @"order_position";
NSString * const COL_DESCRIPTION = @"description";
NSString * const COL_HTML_DESCRIPTION = @"html_description_source";
NSString * const COL_HTML_DESCRIPTION_ENABLED = @"enable_html_description";
NSString * const COL_COVERAGE_TYPE = @"coverage_type";
NSString * const COL_IMAGE_URL_REMOTE = @"image_url";
NSString * const COL_IMAGE_UPDATED = @"image_updated";
NSString * const COL_QUALITY_MANUAL_UPDATED = @"quality_manual_updated";
NSString * const COL_THRESHOLDS = @"thresholds";
NSString * const COL_START_DATE = @"start_date";
NSString * const COL_END_DATE = @"end_date";
NSString * const COL_DISTINCT_PRODUCTS = @"distinct_products";
NSString * const COL_VERSION = @"version";
NSString * const COL_STORE_IDS = @"store_ids";
NSString * const COL_PRODUCT_NAME = @"product_name";
NSString * const COL_DAYS_REMAINING = @"DAYS_REMAINING";
NSString * const COL_DAYS_REMAINING_MAX = @"DAYS_REMAINING_MAX";
NSString * const COL_COMMODITY = @"commodity";
NSString * const COL_RATING_DEFECTS = @"rating_defects";
NSString * const COL_VARIETY = @"variety";
NSString * const COL_UPC = @"upc";
NSString * const COL_PLU = @"plu";
NSString * const COL_SKUS = @"skus";
NSString * const COL_INSIGHTS_PRODUCT = @"insights_product";
NSString * const COL_GROUP_ID = @"group_id";
NSString * const COL_DEFAULT_STAR = @"default_star";
NSString * const COL_REQUIRE_HM_CODE = @"require_hm_code";
NSString * const COL_QUALITY_MANUAL_URL = @"quality_manual";
NSString * const COL_URL = @"url";
NSString * const COL_QUALITY_MANUAL_CONTENT = @"quality_manual_content";
NSString * const COL_AUDIT_COUNT = @"audit_count";
NSString * const COL_RATINGS = @"ratings";
NSString * const COL_AUDIT_COUNT_DATA = @"audit_count_data";
NSString * const COL_RATINGS_ID_ARRAY = @"ratingIdsArray";
NSString * const COL_DEFECTS_ID_ARRAY = @"defectIdsArray";
NSString * const COL_CONTENT = @"content";
NSString * const COL_TYPE = @"type";
NSString * const COL_ORDER_DATA_FIELD = @"order_data_field";
NSString * const COL_ADDRESS = @"address";
NSString * const COL_CHAIN_NAME = @"chain_name";
NSString * const COL_LAT = @"lat";
NSString * const COL_LON = @"lon";
NSString * const COL_CITY = @"city";
NSString * const COL_STATE = @"state";
NSString * const COL_COUNTRY = @"country";
NSString * const COL_GLN = @"gln";
NSString * const COL_POSTCODE = @"postCode";
NSString * const COL_STORE_NUMBER = @"store_number";
NSString * const COL_GEO_POINT = @"geo_point";
NSString * const COL_MARKETING_SALES_AREA = @"marketing_sales_area";
NSString * const COL_SALES_VOLUME = @"sales_volume";
NSString * const COL_BANNER_ID = @"banner_id";
NSString * const COL_SHORT_NAME = @"short_name";
NSString * const COL_COMPANY_NAME = @"company_name";
NSString * const COL_COMPANY_ID = @"company_id";
NSString * const COL_ARCHIVED = @"archived";
NSString * const COL_AUDIT_ID = @"AUDIT_ID";
NSString * const COL_AUDIT_LOG = @"AUDIT_LOG";
NSString * const COL_OPTIONAL_SETTINGS = @"optional_settings";
NSString * const COL_TOTAL = @"total";
NSString * const COL_ACCEPT_ISSUES_TOTAL = @"accept_issues_total";
NSString * const COL_SEVERITY_TOTALS = @"severity_totals";
NSString * const COL_RATING_ID = @"rating_id";
NSString * const COL_API_NAME = @"apiName";
NSString * const COL_API_JSON_DEVICE_URL = @"apiJsonDeviceUrl";
NSString * const COL_REMOTE_URL = @"REMOTE_URL";
NSString * const COL_DEVICE_URL = @"DEVICE_URL";
NSString * const COL_STAR_RATING_NUMBER = @"STAR_RATING_NUMBER";
NSString * const COL_INSPECTION_NAME = @"INSPECTION_NAME";
NSString * const COL_SUMMARY = @"SUMMARY";
NSString * const COL_DATE_FINISHED = @"DATE_FINISHED";
NSString * const COL_DATE_SUBMITTED = @"DATE_SUBMITTED";
NSString * const COL_IMAGE_COUNT = @"IMAGE_COUNT";
NSString * const COL_DEFECT_GROUP_ID = @"defect_group_id";
NSString * const COL_DEFECT_GROUP_NAME = @"defect_group_name";
NSString * const COL_USERENTERED_SAMPLES = @"user_entered_inspection_samples";
NSString * const COL_USERENTERED_NOTIFICATION = @"user_entered_notification";
NSString * const COL_CONTAINERS = @"containers";
NSString * const COL_INSPECTION_MINIMUMS_ID = @"INSPECTION_MIN_ID";
NSString * const COL_IS_NUMERIC = @"is_numeric";
NSString * const COL_APPLY_TO_ALL = @"apply_to_all";

//Order Data
NSString * const COL_ORDER_ID = @"ORDER_ID";
NSString * const COL_ORDER_DCNAME = @"ORDER_DC_NAME";
NSString * const COL_ORDER_RECEIVED_DATETIME = @"ORDER_RECEIVED_DATETIME";
NSString * const COL_ORDER_DELIVERY_EXPECTED_DATETIME = @"ORDER_DELIVERY_EXPECTED_DATETIME";
NSString * const COL_ORDER_PO_NUMBER = @"ORDER_PO_NUMBER";
NSString * const COL_ORDER_GRN = @"ORDER_GRN";
NSString * const COL_ORDER_PO_LINE_NUMBER = @"ORDER_PO_LINE_NUMBER";
NSString * const COL_ORDER_ITEM_NUMBER = @"ORDER_ITEM_NUMBER";
NSString * const COL_ORDER_ITEM_NAME = @"ORDER_ITEM_NAME";
NSString * const COL_ORDER_VENDOR_CODE = @"ORDER_VENDOR_CODE";
NSString * const COL_ORDER_VENDOR_NAME = @"ORDER_VENDOR_NAME";
NSString * const COL_ORDER_QUANTITY_OF_ITEMS_IN_CASE = @"ORDER_QUANTITY_OF_ITEMS_IN_CASE";
NSString * const COL_ORDER_QUANTITY_OF_ITEMS = @"ORDER_QUANTITY_OF_ITEMS";
NSString * const COL_ORDER_QUANTITY_OF_CASES = @"ORDER_QUANTITY_OF_CASES";
NSString * const COL_ORDER_WEIGHT = @"ORDER_WEIGHT";
NSString * const COL_ORDER_WEIGHT_UOM = @"ORDER_WEIGHT_UOM";
NSString * const COL_ORDER_PO_LINE_NUMBER_VALUE = @"ORDER_PO_LINE_NUMBER_VALUE";
NSString * const COL_ORDER_CARRIER_NAME = @"ORDER_CARRIER_NAME";
NSString * const COL_ORDER_PROGRAM_NAME = @"ORDER_PROGRAM_NAME";
NSString * const COL_ORDER_LOAD_ID = @"ORDER_LOAD_ID";
NSString * const COL_ORDER_FLAGGED_PRODUCT = @"ORDER_FLAGGED_PRODUCT";
NSString * const COL_ORDER_MESSAGE = @"ORDER_MESSAGE";
NSString * const COL_ORDER_SCORE = @"ORDER_SCORE";
NSString * const COL_ORDER_FLAGGED_MESSAGES = @"ORDER_FLAGGED_MESSAGES";
NSString * const COL_ORDER_FLAGGED_SCORE = @"ORDER_FLAGGED_SCORE";
NSString * const COL_ORDER_FLAGGED_MESSAGES_ALL = @"ORDER_FLAGGED_MESSAGES_ALL";
NSString * const COL_ORDER_CUSTOMER_CODE = @"ORDER_CUSTOMER_CODE";
NSString * const COL_ORDER_CUSTOMER_NAME = @"ORDER_CUSTOMER_NAME";


NSString * const RATING_FOR_AVERAGE_COUNT_STRING = @"COUNT OF CASES";


NSString * const SQLITE_TYPE_INTEGER = @"INTEGER";
NSString * const SQLITE_TYPE_TEXT = @"TEXT";
NSString * const SQLITE_TYPE_BLOB =@"BLOB";
NSString * const SQLITE_TYPE_PRIMARY_KEY =@"PRIMARY KEY";

// Inspection Status
// Strings for Inspection Status dropdown
NSString * const INSPECTION_STATUS_ACCEPT = @"Accept";
NSString * const INSPECTION_STATUS_ACCEPT_WITH_ISSUES = @"Accept with Issues";
NSString * const INSPECTION_STATUS_REJECT = @"Reject";
NSString * const INSPECTION_STATUS_NONE = @"";
NSString * const COL_INSPECTION_STATUS = @"INSPECTION_STATUS";


@end
