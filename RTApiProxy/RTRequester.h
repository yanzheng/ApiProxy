//
//  RTRequester.h
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTDispatcher.h"

// ASI headers
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "ASIDownloadCache.h"

#define RT_MIN_REQUESTID 1
#define RT_MAX_REQUESTID UINT_MAX 

@interface RTRequester : NSObject {
    RTDispatcher *_dispatcher;
    RTRequestID _lastRequestID;
    ASINetworkQueue *_ASIQueue;
}

+ (id)sharedInstance;
- (id)init;

- (RTRequestID)httpGet:(NSURL *)url serivce:(RTServiceType)serviceID target:(id)target action:(SEL)action;
- (RTRequestID)httpPost:(NSURL *)url params:(NSDictionary *)params serivce:(RTServiceType)serviceID target:(id)target action:(SEL)action;

//New upload
- (RTRequestID)httpPost:(NSURL *)url params:(NSDictionary *)params files:(NSDictionary *)files serivce:(RTServiceType)serviceID target:(id)target action:(SEL)action;
- (RTNetworkResponse *)httpPostFileSync:(NSURL *)url serivce:(RTServiceType)serviceID params:(NSDictionary *)params files:(NSDictionary *)files;

- (RTNetworkResponse *)httpGetSync:(NSURL *)url service:(RTServiceType)serviceID;
- (RTNetworkResponse *)httpPostSync:(NSURL *)url service:(RTServiceType)serviceID body:(NSDictionary *)params;

- (void)cancelRequest:(RTRequestID)requestID;
- (void)cancelRequestsWithTarget:(id)target;

- (RTNetworkResponse *)generateSyncResponse:(ASIHTTPRequest *)request service:(RTServiceType)serviceID;
    
- (BOOL)isInternetAvailiable;
- (BOOL)isWiFiAvailiable;
- (NSString *)getNetworkStatus;


@end
