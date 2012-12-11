//
//  RTApiProxyResponse.h
//  RTApiProxy
//
//  Created by yanzheng on 3/6/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RTApiResponseNotification @"RTApiResonseNotification"

#define RTGeoServiceID 1
#define RTDituGeoServiceID 2
#define RTImageServiceID 3

typedef unsigned int RTServiceType;
typedef unsigned int RTRequestID;
#define RT_ERROR_REQUESTID 0

typedef enum _RTNetworkResponseStatus {
    RTNetworkResponseStatusSuccess,
    RTNetworkResponseStatusFailed = 0x1000,
    RTNetworkResponseStatusJsonError = 0x1001,
} RTNetworkResponseStatus;

@interface RTNetworkResponse : NSObject

@property (nonatomic, assign) RTRequestID requestID;
@property (nonatomic, assign) RTNetworkResponseStatus status;
@property (nonatomic, retain) NSDictionary *content;

@end
