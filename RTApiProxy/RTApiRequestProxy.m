//
//  RTRequestProxy.m
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import "RTApiRequestProxy.h"
#import "RTRequester.h"
#import "RTDispatcher.h"
#import "RTImageService.h"
#import "RTGeoService.h"

// private methods
@interface RTApiRequestProxy () {
    RTRequester *_requester;
    NSMutableDictionary *_serviceDict;
}

@end

@implementation RTApiRequestProxy

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static RTApiRequestProxy *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RTApiRequestProxy alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _requester = [RTRequester sharedInstance];
        _serviceDict = [[RTDispatcher sharedInstance] serviceDict];
        
        RTGeoService *geoService = [[[RTGeoService alloc] init] autorelease];
        RTImageService *imageService = [[[RTImageService alloc] init] autorelease];
        
        [self registerService:geoService];  // geo serviceID is 1
        [self registerService:imageService];    // image serviceID is 2
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    // implement -dealloc & remove abort() when refactoring for
    // non-singleton use.
    abort();
}

- (RTServiceType)registerService:(RTBaseService *)service {
    RTServiceType newServiceID = [_serviceDict count]+1;
    [service setServiceID:newServiceID];
    [_serviceDict setObject:service forKey:[NSNumber numberWithInt:newServiceID]];
    return newServiceID;
}

#pragma mark - Image requests
- (RTNetworkResponse *)syncFetchImage:(NSURL *)imageURL{
    RTServiceType serviceID = RTImageServiceID;
    return [_requester httpGetSync:imageURL service:serviceID];
}

- (RTRequestID)fetchImage:(NSURL *)imageURL target:(id)target action:(SEL)action {
    RTServiceType serviceID = RTImageServiceID;
    return [_requester httpGet:imageURL serivce:serviceID target:target action:action];
}


#pragma mark - Geo requests
- (RTNetworkResponse *)syncGeoWithLat:(NSString *)lat lng:(NSString *)lng {
    RTServiceType serviceID = RTGeoServiceID;
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
    NSString *latlng = [NSString stringWithFormat:@"%@,%@", lat, lng];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"sensor", @"zh-CN", @"language", latlng, @"latlng", nil];
    NSURL *requestURL = [service buildGetURLWithMethod:@"maps/api/geocode/json?" params:paramsDict];

    return [_requester httpGetSync:requestURL service:serviceID];
}

- (RTNetworkResponse *)syncGeoWithAddress:(NSString *)address {
    RTServiceType serviceID = RTGeoServiceID;
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];

    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"sensor", @"zh-CN", @"language", address, @"address", nil];
    NSURL *requestURL = [service buildGetURLWithMethod:@"maps/api/geocode/json?" params:paramsDict];
    
#ifdef DEBUG
    NSLog(@"google geo url: %@", requestURL);
#endif
    return [_requester httpGetSync:requestURL service:serviceID];
}


- (RTRequestID)geoWithLat:(NSString *)lat lng:(NSString *)lng target:(id)target action:(SEL)action {
    RTServiceType serviceID = RTGeoServiceID;
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
    NSString *latlng = [NSString stringWithFormat:@"%@,%@", lat, lng];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"sensor", @"zh-CN", @"language", latlng, @"latlng", nil];
    NSURL *requestURL = [service buildGetURLWithMethod:@"maps/api/geocode/json?" params:paramsDict];
    
    return [_requester httpGet:requestURL serivce:serviceID target:target action:action];
}

- (RTRequestID)geoWithAddress:(NSString *)address target:(id)target action:(SEL)action {
    RTServiceType serviceID = RTGeoServiceID;
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
    
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"sensor", @"zh-CN", @"language", address, @"address", nil];
    NSURL *requestURL = [service buildGetURLWithMethod:@"maps/api/geocode/json?" params:paramsDict];
    
    return [_requester httpGet:requestURL serivce:serviceID target:target action:action];
}


#pragma mark - General requests
- (RTNetworkResponse *)syncGetWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params {
    if (!methodName)
        return RT_ERROR_REQUESTID;
    
    // check params
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        return RT_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
        
    NSURL *requestURL = [service buildGetURLWithMethod:methodName params:params];
#if DEBUG
    NSLog(@"%@",requestURL);
#endif
    return [_requester httpGetSync:requestURL service:serviceID];
}
- (RTNetworkResponse *)syncPostWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params {
    if (!methodName)
        return RT_ERROR_REQUESTID;
    
    // check params
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        return RT_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
        

    NSURL *requestURL = [service buildPostURLWithMethod:methodName params:params];
    return [_requester httpPostSync:requestURL service:serviceID body:params];    
}


- (RTRequestID)asyncGetWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action {
    if (!methodName)
        return RT_ERROR_REQUESTID;
    
    // check params
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        NSLog(@"RTRequestProxy::asyncGetWithServiceID: params is not kind of NSDictionary: %@", params);
        return RT_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
        
    NSURL *requestURL = [service buildGetURLWithMethod:methodName params:params];
    return [_requester httpGet:requestURL serivce:serviceID target:target action:action];
}

- (RTRequestID)asyncPostWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params target:(id)target action:(SEL)action {
    // check method
    if (!methodName)
        return RT_ERROR_REQUESTID;
    
    // check params
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        NSLog(@"RTRequestProxy::asyncPostWithServiceID: params is not kind of NSDictionary: %@", params);
        return RT_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
        
    NSURL *requestURL = [service buildPostURLWithMethod:methodName params:params];
    return [_requester httpPost:requestURL params:params serivce:serviceID target:target action:action];
}


#pragma mark - Upload file
- (RTRequestID)asyncPostWithServiceID:(RTServiceType)serviceID methodName:(NSString *)methodName params:(NSDictionary *)params files:(NSDictionary *)files target:(id)target action:(SEL)action{
    // check method
    if (!methodName)
        return RT_ERROR_REQUESTID;
    
    // check params
    if (files && ![files isKindOfClass:[NSDictionary class]]) {
        NSLog(@"RTRequestProxy::asyncPostWithServiceID: files is not kind of NSDictionary: %@", files);
        return RT_ERROR_REQUESTID;
    }
    
    id service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
        
    NSURL *requestURL = [service buildPostURLWithMethod:methodName params:params];
#ifdef DEBUG
    NSLog(@"requestURL %@",requestURL);
#endif
    return [_requester httpPost:requestURL params:params files:files serivce:serviceID target:target action:action];
}


- (RTNetworkResponse *)syncUploadWithServiceID:(RTServiceType) serviceID url:(NSURL *)url files:(NSDictionary *)files {
    // check params
    if (files && ![files isKindOfClass:[NSDictionary class]]) {
        NSLog(@"RTRequestProxy::asyncPostWithServiceID: files is not kind of NSDictionary: %@", files);
        return RT_ERROR_REQUESTID;
    }
    
    return [_requester httpPostFileSync:url serivce:serviceID params:nil files:files];
}


#pragma mark - Cancel requests
- (void)cancelRequest:(RTRequestID)requestID {
    [_requester cancelRequest:requestID];
}

- (void)cancelRequestsWithTarget:(id)target {
    [_requester cancelRequestsWithTarget:target];
}


#pragma mark - Network status
- (BOOL)isInternetAvailiable {
    return [_requester isInternetAvailiable]; 
}

- (BOOL)isWiFiAvailiable {
    return [_requester isWiFiAvailiable];
}

- (NSString *)getNetworkStatus {
    return [_requester getNetworkStatus];
}


@end
