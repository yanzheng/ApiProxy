//
//  DispatchElement.h
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTBaseService.h"
#import "ASIHTTPRequest.h"

@interface DispatchElement : NSObject

@property (nonatomic, assign) RTRequestID requestID;
@property (nonatomic, assign) id    target;
@property (nonatomic, assign) SEL   callback;
@property (nonatomic, assign) RTServiceType serviceID;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSDate *startTime;

- (id)init;

@end
