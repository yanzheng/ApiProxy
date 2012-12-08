//
//  DispatchElement.m
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import "DispatchElement.h"

@implementation DispatchElement
@synthesize requestID = _requestID;
@synthesize target = _target;
@synthesize callback = _callback;
@synthesize serviceID = _serviceID;
@synthesize request = _request;
@synthesize startTime = _startTime;

- (id) init {
    self = [super init];
    if (self) {
        self.startTime = [NSDate date];        
    }
    
    return self;
}

- (void) dealloc {
    [_request release];
    [_startTime release];
    
    [super dealloc];
}

@end
