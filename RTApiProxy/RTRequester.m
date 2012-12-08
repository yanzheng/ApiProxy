//
//  RTRequester.m
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import "RTRequester.h"
#import "RTDispatcher.h"
#import "DispatchElement.h"
#import "Reachability.h"
#import "NSObject+SBJson.h"

@implementation RTRequester


+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static RTRequester *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RTRequester alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _dispatcher = [RTDispatcher sharedInstance];
        _lastRequestID = RT_MIN_REQUESTID;
        _ASIQueue = [[ASINetworkQueue alloc] init];
        
        // When a request in this queue fails or is cancelled, other requests will continue to run
        [_ASIQueue setShouldCancelAllRequestsOnFailure:NO];
        [_ASIQueue go];
    }
    return self;
}

- (ASIHTTPRequest *)requestWithURL:(NSURL *)url {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [(ASIHTTPRequest *)request setShouldRedirect:NO];

    return request;
}

- (ASIFormDataRequest *)formRequestWithURL:(NSURL *)url {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [(ASIHTTPRequest *)request setShouldRedirect:NO];

    return request;
}


- (RTRequestID)httpGet:(NSURL *)url serivce:(RTServiceType)serviceID target:(id)target action:(SEL)action {
    if (++_lastRequestID >= RT_MAX_REQUESTID)
        _lastRequestID = RT_MIN_REQUESTID;
    
    ASIHTTPRequest *request = [self requestWithURL:url];
    [request setAllowCompressedResponse:YES];
    
    if (serviceID == RTImageServiceID) {
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
        [request setAllowResumeForFileDownloads:YES];
        [request setDownloadDestinationPath:[[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:request]];
        [request setSecondsToCache:60*60*24*3];
    }
    
    DispatchElement *element = [[DispatchElement alloc] init];
    [element setTarget:target];
    [element setCallback:action];
    [element setServiceID:serviceID];
    [element setRequestID:_lastRequestID];
    [element setRequest:request];
    
    [_dispatcher addDispatchItem:element];
    [_ASIQueue addOperation:request]; 
    [element release];
    
//    NSLog(@"HTTP Get[%d]:%@", _lastRequestID, url);
    return _lastRequestID;
}

- (RTRequestID)httpPost:(NSURL *)url params:(NSDictionary *)params serivce:(RTServiceType)serviceID target:(id)target action:(SEL)action {
    if (++_lastRequestID >= RT_MAX_REQUESTID)
        _lastRequestID = RT_MIN_REQUESTID;
    
    ASIFormDataRequest *request = [self formRequestWithURL:url];
    
    if (params) {
        NSArray *keys = [params allKeys];
        for (NSString *key in keys) {
            if ([[NSNull null] isEqual:[params objectForKey:key]] || [@"" isEqualToString:[params objectForKey:key]])
                continue;
            
            [request addPostValue:[params objectForKey:key] forKey:key];
        }
    } 
    
    DispatchElement *element = [[[DispatchElement alloc] init] autorelease];
    [element setTarget:target];
    [element setCallback:action];
    [element setServiceID:serviceID];
    [element setRequestID:_lastRequestID];
    [element setRequest:request];
    
    [_dispatcher addDispatchItem:element];
    [_ASIQueue addOperation:request]; 
    
//    NSLog(@"HTTP Post[%d]:%@", _lastRequestID, url);
    return _lastRequestID;
}


//New upload
- (RTRequestID)httpPost:(NSURL *)url params:(NSDictionary *)params files:(NSDictionary *)files serivce:(RTServiceType)serviceID target:(id)target action:(SEL)action {
    if (++_lastRequestID >= RT_MAX_REQUESTID)
        _lastRequestID = RT_MIN_REQUESTID;
    
    ASIFormDataRequest *request = [self formRequestWithURL:url];
    
    if (params) {
        NSArray *keys = [params allKeys];
        for (NSString *key in keys) {
            if ([[NSNull null] isEqual:[params objectForKey:key]] || [@"" isEqualToString:[params objectForKey:key]])
                continue;
            
            [request addPostValue:[params objectForKey:key] forKey:key];
        }
    }
    if (files) {
        NSArray *keys = [files allKeys];
        for (NSString *key in keys) {
            if ([[NSNull null] isEqual:[files objectForKey:key]] || [@"" isEqualToString:[files objectForKey:key]])
                continue;

            [request addFile:[files objectForKey:key] forKey:key];
        }
    } 
    
    DispatchElement *element = [[[DispatchElement alloc] init] autorelease];
    [element setTarget:target];
    [element setCallback:action];
    [element setServiceID:serviceID];
    [element setRequestID:_lastRequestID];
    [element setRequest:request];
    
    [_dispatcher addDispatchItem:element];
    [_ASIQueue addOperation:request]; 
    
//    NSLog(@"HTTP Post[%d]:%@", _lastRequestID, url);
    return _lastRequestID;
}

- (RTNetworkResponse *)httpPostFileSync:(NSURL *)url serivce:(RTServiceType)serviceID params:(NSDictionary *)params files:(NSDictionary *)files{
    
    ASIFormDataRequest *request = [self formRequestWithURL:url];
    if (params) {
        NSArray *keys = [params allKeys];
        for (NSString *key in keys) {
            if (![[NSNull null] isEqual:[params objectForKey:key]] &&
                ![@"" isEqualToString:[params objectForKey:key]]) {
                [request addPostValue:[params objectForKey:key] forKey:key];
            }
        }
    }
    if (files) {
        NSArray *keys = [files allKeys];
        for (NSString *key in keys) {
            if ([[NSNull null] isEqual:[files objectForKey:key]] || [@"" isEqualToString:[files objectForKey:key]])
                continue;
            [request addFile:[files objectForKey:key] forKey:key];
        }
    }
    
    [request startSynchronous];
    return [self generateSyncResponse:request service:serviceID];
}

- (RTNetworkResponse *)httpGetSync:(NSURL *)url service:(RTServiceType)serviceID {
//    NSLog(@"HTTP Get Sync:%@", url);
    
    ASIHTTPRequest *request = [self requestWithURL:url];
    if (serviceID == RTImageServiceID) {
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
        [request setAllowResumeForFileDownloads:YES];
        [request setDownloadDestinationPath:[[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:request]];
        [request setSecondsToCache:60*60*24*3];
    }
    
    [request startSynchronous];
    return [self generateSyncResponse:request service:serviceID];
}

- (RTNetworkResponse *)httpPostSync:(NSURL *)url service:(RTServiceType)serviceID body:(NSDictionary *)params {
//    NSLog(@"HTTP Post Sync:%@", url);

    ASIFormDataRequest *request = [self formRequestWithURL:url];
    if (params) {
        NSArray *keys = [params allKeys];
        for (NSString *key in keys) {
            if (![[NSNull null] isEqual:[params objectForKey:key]] && 
                ![@"" isEqualToString:[params objectForKey:key]]) {
                [request addPostValue:[params objectForKey:key] forKey:key];
            }
        }
    } 
    
    [request startSynchronous];
    return [self generateSyncResponse:request service:serviceID];
}


- (RTNetworkResponse *)generateSyncResponse:(ASIHTTPRequest *)request service:(RTServiceType)serviceID {
    RTNetworkResponse *response = [[[RTNetworkResponse alloc] init] autorelease];
    NSError *error = [request error];
    if (error) {
        [response setStatus:RTNetworkResponseStatusFailed];
        return response;
    }
    
    [response setStatus:RTNetworkResponseStatusSuccess];
    if (serviceID == RTImageServiceID)
        [response setContent:[NSDictionary dictionaryWithObjectsAndKeys:[request downloadDestinationPath], @"imagePath", @"OK", @"status", nil]];
    else {
        NSString *result = [request responseString];
        [response setContent:(NSDictionary *)[result JSONValue]];
    }
    
    return response;
}

- (void)cancelRequest:(RTRequestID)requestID {
    [_dispatcher cancelRequest:requestID];
}

- (void)cancelRequestsWithTarget:(id)target {
    [_dispatcher cancelRequestsWithTarget:target];
}


- (BOOL)isInternetAvailiable {
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

- (BOOL)isWiFiAvailiable {
    return [[Reachability reachabilityForInternetConnection] isReachableViaWiFi];    
}

- (NSString *)getNetworkStatus {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN) 
        return @"2G3G";
    else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi)
        return @"WiFi";
    else
        return @"";
}

@end
