//
//  RTRequestProxy.h
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTNetworkResponse.h"
#import "RTBaseService.h"

@interface RTApiRequestProxy : NSObject {
}

+ (id)sharedInstance;
- (id)init;

- (RTServiceType)registerService:(RTBaseService *)service;

#pragma mark - Image request
- (RTNetworkResponse *)syncFetchImage:(NSURL *)imageURL;
- (RTRequestID)fetchImage:(NSURL *)imageURL target:(id)target action:(SEL)action;

#pragma mark - Geo request
- (RTNetworkResponse *)syncGeoWithLat:(NSString *)lat lng:(NSString *)lng;
- (RTRequestID)geoWithLat:(NSString *)lat lng:(NSString *)lng target:(id)target action:(SEL)action;
- (RTNetworkResponse *)syncGeoWithAddress:(NSString *)address;
- (RTRequestID)geoWithAddress:(NSString *)address target:(id)target action:(SEL)action;
- (RTRequestID)dituGeoWithAddress:(NSString *)address target:(id)target action:(SEL)action;
- (RTNetworkResponse *)syncDituGeoWithAddress:(NSString *)address;

#pragma mark - Generic request
- (RTRequestID)asyncGetWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action;
- (RTRequestID)asyncPostWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action;
- (RTNetworkResponse *)syncGetWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params;
- (RTNetworkResponse *)syncPostWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params;

#pragma mark - File request
- (RTRequestID)asyncPostWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params files:(NSDictionary *)files target:(id)target action:(SEL)action;
- (RTNetworkResponse *)syncUploadWithServiceID:(RTServiceType) serviceID url:(NSURL *)url files:(NSDictionary *)files;

#pragma mark - Cancel request
- (void)cancelRequest:(RTRequestID)requestID;
- (void)cancelRequestsWithTarget:(id)target;

#pragma mark - Network status
- (BOOL)isInternetAvailiable;
- (BOOL)isWiFiAvailiable;
- (NSString *)getNetworkStatus;

@end
