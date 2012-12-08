//
//  RTBaseService.h
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTNetworkResponse.h"

@interface RTBaseService : NSObject {
    
}

@property (nonatomic, copy) NSString *apiSite;
@property (nonatomic, assign) RTServiceType serviceID;

- (NSURL *)buildGetURLWithMethod:(NSString *)methodName params:(NSDictionary *)params;
- (NSURL *)buildPostURLWithMethod:(NSString *)methodName params:(NSDictionary *)params;

- (NSDictionary *)parse:(NSString *)response;

@end
