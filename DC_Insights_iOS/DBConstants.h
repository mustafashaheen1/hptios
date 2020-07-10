//
//  DBConstants.h
//  DC_Insights_iOS
//
//  Created by Vineet Pareek on 3/24/14.
//  Copyright (c) 2014 Yottamark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBConstants : NSObject


/* --- SQLITE Constants --- */

// Databases
extern NSString * const DB_APP_DATA;
extern NSString * const DB_INSIGHTS_DATA;
extern NSString * const DB_OFFLINE_DATA;
extern NSString * const DB_ORDER_DATA;
// Preferences
extern NSString * const PREF_AUDIT_MASTER_ID;
extern NSString * const PREF_CONTAINER_RATINGS;
extern NSString * const PREF_INSPECTION_ACTIVE;
extern NSString * const AUTH_TOKEN;
extern NSString * const LAST_SYNC_DATE;
extern NSString * const LOGIN_CREDS;
extern NSString * const USER_NAME;

// SQLite Tables
extern NSString * const TBL_USERS;
extern NSString * const TBL_COMPLETED_AUDITS;
extern NSString * const TBL_USER_ENTERED_STORES;
extern NSString * const TBL_SAVED_AUDITS;
extern NSString * const TBL_SAVED_CONTAINERS;
extern NSString * const TBL_SAVED_SUMMARY;
extern NSString * const TBL_CONTAINERS;
extern NSString * const TBL_CONTAINER_RATINGS;
extern NSString * const TBL_CONTAINER_RATING_CONDITIONS;
extern NSString * const TBL_PROGRAMS;
extern NSString * const TBL_PRODUCTS;
extern NSString * const TBL_GROUP_RATINGS;
extern NSString * const TBL_DEFECT_FAMILIES;
extern NSString * const TBL_DEFECT_FAMILY_DEFECTS;
extern NSString * const TBL_RATINGS;
extern NSString * const TBL_STORES;
extern NSString * const TBL_LOCATIONS;
extern NSString * const TBL_GROUPS;
extern NSString * const TBL_APP_LOGS;
extern NSString * const TBL_API_JSON;
extern NSString * const TBL_DEFECT_IMAGES;
extern NSString * const TBL_STAR_RATING_IMAGES;
extern NSString * const TBL_PRODUCT_QUALITY_MANUAL;
extern NSString * const TBL_ORDERDATA;
extern NSString * const TBL_SUBMITTED_AUDITS;
extern NSString * const TBL_COLLABORATIVE_LOCAL_UPDATES;
extern NSString * const TBL_COLLABORATIVE_SAVE_REQUESTS;
extern NSString * const TBL_INSPECTION_MINIMUMS;

// SQLite Columns
extern NSString * const COL_USERNAME;
extern NSString * const COL_PASSWORD;
extern NSString * const COL_AUDIT_DATA;
extern NSString * const COL_AUDIT_IMAGE;
extern NSString * const COL_DATA_SUBMITTED;
extern NSString * const COL_DATA_COMPLETED_TIME;
extern NSString * const COL_DATA_SUBMITTED_TIME;
extern NSString * const COL_IMAGE_SUBMITTED;
extern NSString * const COL_IMAGES;
extern NSString * const COL_ID;
extern NSString * const COL_NAME;
extern NSString * const COL_SPLIT_GROUP_ID;
extern NSString * const COL_NOTIFICATION_CHANGED;
extern NSString * const COL_AUDIT_MASTER_ID;
extern NSString * const COL_AUDIT_GROUP_ID;
extern NSString * const COL_AUDIT_JSON;
extern NSString * const COL_AUDIT_PRODUCT_ID;
extern NSString * const COL_IMAGE_COUNT;
extern NSString * const COL_INSP_STATUS;
extern NSString * const COL_AUDITS_COMPLETED;
extern NSString * const COL_PROGRAM_ID;
extern NSString * const COL_PRODUCT_ID;
extern NSString * const COL_PRODUCT_GROUP_ID;
extern NSString * const COL_COUNT_OF_CASES;
extern NSString * const COL_INSPECTION_COUNT_OF_CASES;
extern NSString * const COL_PARENT_ID;
extern NSString * const COL_PIC_REQUIRED;
extern NSString * const COL_CONTAINER_ID;
extern NSString * const COL_DEFECT_FAMILY_ID;
extern NSString * const COL_DEFECTS;
extern NSString * const COL_ORDER_POSITION;
extern NSString * const COL_DISPLAY_NAME;
extern NSString * const COL_DESCRIPTION;
extern NSString * const COL_HTML_DESCRIPTION;
extern NSString * const COL_HTML_DESCRIPTION_ENABLED;
extern NSString * const COL_COVERAGE_TYPE;
extern NSString * const COL_IMAGE_URL_REMOTE;
extern NSString * const COL_IMAGE_UPDATED;
extern NSString * const COL_QUALITY_MANUAL_UPDATED;
extern NSString * const COL_THRESHOLDS;
extern NSString * const COL_START_DATE;
extern NSString * const COL_END_DATE;
extern NSString * const COL_DISTINCT_PRODUCTS;
extern NSString * const COL_VERSION;
extern NSString * const COL_STORE_IDS;
extern NSString * const COL_PRODUCT_NAME;
extern NSString * const COL_DAYS_REMAINING;
extern NSString * const COL_DAYS_REMAINING_MAX;
extern NSString * const COL_RATING_DEFECTS;
extern NSString * const COL_COMMODITY;
extern NSString * const COL_VARIETY;
extern NSString * const COL_UPC;
extern NSString * const COL_PLU;
extern NSString * const COL_SKUS;
extern NSString * const COL_INSIGHTS_PRODUCT;
extern NSString * const COL_GROUP_ID;
extern NSString * const COL_DEFAULT_STAR;
extern NSString * const COL_REQUIRE_HM_CODE;
extern NSString * const COL_QUALITY_MANUAL_URL;
extern NSString * const COL_URL;
extern NSString * const COL_QUALITY_MANUAL_CONTENT;
extern NSString * const COL_AUDIT_COUNT;
extern NSString * const COL_RATINGS;
extern NSString * const COL_AUDIT_COUNT_DATA;
extern NSString * const COL_RATINGS_ID_ARRAY;
extern NSString * const COL_DEFECTS_ID_ARRAY;
extern NSString * const COL_CONTENT;
extern NSString * const COL_TYPE;
extern NSString * const COL_ORDER_DATA_FIELD;
extern NSString * const COL_ADDRESS;
extern NSString * const COL_CHAIN_NAME;
extern NSString * const COL_LAT;
extern NSString * const COL_LON;
extern NSString * const COL_CITY;
extern NSString * const COL_STATE;
extern NSString * const COL_COUNTRY;
extern NSString * const COL_GLN;
extern NSString * const COL_POSTCODE;
extern NSString * const COL_STORE_NUMBER;
extern NSString * const COL_GEO_POINT;
extern NSString * const COL_MARKETING_SALES_AREA;
extern NSString * const COL_SALES_VOLUME;
extern NSString * const COL_BANNER_ID;
extern NSString * const COL_SHORT_NAME;
extern NSString * const COL_COMPANY_NAME;
extern NSString * const COL_COMPANY_ID;
extern NSString * const COL_ARCHIVED;
extern NSString * const COL_AUDIT_ID;
extern NSString * const COL_AUDIT_LOG;
extern NSString * const COL_OPTIONAL_SETTINGS;
extern NSString * const COL_TOTAL;
extern NSString * const COL_SEVERITY_TOTALS;
extern NSString * const COL_ACCEPT_ISSUES_TOTAL;
extern NSString * const COL_RATING_ID;
extern NSString * const COL_API_NAME;
extern NSString * const COL_API_JSON_DEVICE_URL;
extern NSString * const COL_REMOTE_URL;
extern NSString * const COL_DEVICE_URL;
extern NSString * const COL_STAR_RATING_NUMBER;
extern NSString * const COL_INSPECTION_NAME;
extern NSString * const COL_SUMMARY;
extern NSString * const COL_DEFECT_GROUP_ID;
extern NSString * const COL_DEFECT_GROUP_NAME;
extern NSString * const RATING_FOR_AVERAGE_COUNT_STRING;
extern NSString * const COL_USERENTERED_SAMPLES;
extern NSString * const COL_USERENTERED_NOTIFICATION;
extern NSString * const COL_CONTAINERS;
//Order Data
extern NSString * const COL_ORDER_ID;
extern NSString * const COL_ORDER_DCNAME;
extern NSString * const COL_ORDER_RECEIVED_DATETIME;
extern NSString * const COL_ORDER_DELIVERY_EXPECTED_DATETIME;
extern NSString * const COL_ORDER_PO_NUMBER;
extern NSString * const COL_ORDER_GRN;
extern NSString * const COL_ORDER_PO_LINE_NUMBER;
extern NSString * const COL_ORDER_ITEM_NUMBER;
extern NSString * const COL_ORDER_ITEM_NAME;
extern NSString * const COL_ORDER_VENDOR_CODE;
extern NSString * const COL_ORDER_VENDOR_NAME;
extern NSString * const COL_ORDER_QUANTITY_OF_ITEMS_IN_CASE;
extern NSString * const COL_ORDER_QUANTITY_OF_ITEMS;
extern NSString * const COL_ORDER_QUANTITY_OF_CASES;
extern NSString * const COL_ORDER_WEIGHT;
extern NSString * const COL_ORDER_WEIGHT_UOM;
extern NSString * const COL_ORDER_PO_LINE_NUMBER_VALUE;
extern NSString * const COL_ORDER_CARRIER_NAME;
extern NSString * const COL_ORDER_PROGRAM_NAME;
extern NSString * const COL_ORDER_FLAGGED_PRODUCT;
extern NSString * const COL_ORDER_MESSAGE;
extern NSString * const COL_ORDER_SCORE;
extern NSString * const COL_ORDER_FLAGGED_MESSAGES;
extern NSString * const COL_ORDER_FLAGGED_MESSAGES_ALL;
extern NSString * const COL_ORDER_LOAD_ID;
extern NSString * const COL_ORDER_CUSTOMER_CODE;
extern NSString * const COL_ORDER_CUSTOMER_NAME;

extern NSString * const COL_DATE_FINISHED;
extern NSString * const COL_DATE_SUBMITTED;
extern NSString * const COL_IMAGE_COUNT;


extern NSString * const SQLITE_TYPE_INTEGER;
extern NSString * const SQLITE_TYPE_TEXT;
extern NSString * const SQLITE_TYPE_BLOB;
extern NSString * const SQLITE_TYPE_PRIMARY_KEY;


extern NSString * const INSPECTION_STATUS_ACCEPT;
extern NSString * const INSPECTION_STATUS_ACCEPT_WITH_ISSUES;
extern NSString * const INSPECTION_STATUS_REJECT;
extern NSString * const INSPECTION_STATUS_NONE;
extern NSString * const COL_INSPECTION_STATUS;
extern NSString * const COL_INSPECTION_MINIMUMS;
extern NSString * const COL_INSPECTION_MINIMUMS_ID;
extern NSString * const COL_INSPECTION_MINIMUMS_RATING_ID;
extern NSString * const COL_IS_NUMERIC;
extern NSString * const COL_APPLY_TO_ALL;

@end
