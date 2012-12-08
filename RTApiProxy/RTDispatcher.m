//
//  RTDispatcher.m
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import "RTDispatcher.h"

@implementation RTDispatcher
@synthesize serviceDict = _serviceDict;
@synthesize logger = _logger;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static RTDispatcher *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RTDispatcher alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
        self.serviceDict = [NSMutableDictionary dictionary];        
    }
    return self;
}

#pragma mark - Handle requests
- (void)addDispatchItem:(DispatchElement *)item {
    RTRequestID requestID = [item requestID];
    ASIHTTPRequest *ASIRequest = [item request];
    
    [self cancelRequest:requestID];
    
    if ([[item target] conformsToProtocol:@protocol(ASIProgressDelegate)]) {
        [ASIRequest setDownloadProgressDelegate:[item target]];
        [ASIRequest setUploadProgressDelegate:[item target]];
        [ASIRequest setShowAccurateProgress:YES];
    }
    
    [ASIRequest setTag:requestID];
    [ASIRequest setDelegate:self];
    [ASIRequest setDidFinishSelector:@selector(requestFinished:)];
    [ASIRequest setDidFailSelector:@selector(requestFailed:)];
    [ASIRequest setTimeOutSeconds:30];
    [_dispatchTable setObject:item forKey:[NSNumber numberWithInt:requestID]];        
}

- (void)cancelRequest:(RTRequestID)requestID {
    // check if the request id is existed 
    id element = [_dispatchTable objectForKey:[NSNumber numberWithInt:requestID]];
    if (element) {      // cancel request and remove from dispatch table
        [(ASIHTTPRequest *)[element request] clearDelegatesAndCancel];     
        [_dispatchTable removeObjectForKey:[NSNumber numberWithInt:requestID]];
    }
}

- (void)cancelRequestsWithTarget:(id)target {
    NSArray *keyArray = [_dispatchTable allKeys];
    int count = keyArray.count;
    for (int i = 0; i < count; i++) {
        DispatchElement *element =(DispatchElement *)[_dispatchTable objectForKey:[keyArray objectAtIndex:i]];
        if (element != nil && [element target] == target){
            [self cancelRequest:[element requestID]];
        }
    }

}

#pragma mark - Handle responses
- (void)requestFinished:(ASIHTTPRequest *)request
{
    id element = [_dispatchTable objectForKey:[NSNumber numberWithInt:[request tag]]];
    if (!element)
        return;

    // Use when fetching text data
    NSString *responseString = [request responseString];
//    NSLog(@"response: %@", responseString);
    
    RTServiceType serviceID = [element serviceID];
    RTBaseService *service = [_serviceDict objectForKey:[NSNumber numberWithInt:serviceID]];
    
    RTNetworkResponse *response = [[[RTNetworkResponse alloc] init] autorelease];
    [response setRequestID:[request tag]];
    [response setStatus:RTNetworkResponseStatusSuccess];
    if (serviceID == RTImageServiceID)  // 
        [response setContent:[NSDictionary dictionaryWithObjectsAndKeys:[request downloadDestinationPath], @"imagePath", @"OK", @"status", nil]];
    else {
        NSDictionary *jsonDict = [service parse:responseString];
        [response setContent:jsonDict];
        if (!jsonDict)
            [response setStatus:RTNetworkResponseStatusJsonError];
    }
    
    [self dispatchResponse:response forElement:element];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    id element = [_dispatchTable objectForKey:[NSNumber numberWithInt:[request tag]]];
    if (!element)
        return;
    
    RTNetworkResponse *response = [[[RTNetworkResponse alloc] init] autorelease];
    [response setRequestID:[request tag]];
    [response setContent:[NSDictionary dictionaryWithObjectsAndKeys:error, @"ERROR", nil]];
    [response setStatus:RTNetworkResponseStatusFailed];
    
    [self dispatchResponse:response forElement:element];    
}

- (void)dispatchResponse:(RTNetworkResponse *)response forElement:(DispatchElement *)element {
    NSString *status = ([response status] != RTNetworkResponseStatusSuccess) ? @"fail" : @"success";
    NSDictionary *postUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:element.startTime, @"startTime", status, @"status", [[[element request] url] path], @"url", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:RTApiResponseNotification object:self userInfo:postUserInfo];
    
    RTRequestID requestID = [element requestID];    
    id target = [element target];
    SEL callback = [element callback];
    if (target && [target respondsToSelector:callback]) {
		[target performSelector:callback withObject:response];
	}
    
    // remove dispatch item from dispatch table
    [_dispatchTable removeObjectForKey:[NSNumber numberWithInt:requestID]];    
}

@end
