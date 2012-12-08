//
//  RTDispatcher.h
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DispatchElement.h"
#import "RTNetworkResponse.h"

// ASI header
#import "ASIHTTPRequest.h"

@interface RTDispatcher : NSObject {
    NSMutableDictionary *_dispatchTable;
}

@property (nonatomic, retain) NSMutableDictionary *serviceDict;
@property (nonatomic, assign) id logger;

+ (id)sharedInstance;
- (id)init;

- (void)addDispatchItem:item;
- (void)cancelRequest:(RTRequestID)requestID;
- (void)cancelRequestsWithTarget:(id)target;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)dispatchResponse:(RTNetworkResponse *)response forElement:(DispatchElement *)element;


@end
