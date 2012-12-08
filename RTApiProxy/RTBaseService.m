//
//  RTBaseService.m
//  RTApiProxy
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import "RTBaseService.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5Addition.h"
#import "SBJson.h"

@interface RTBaseService() {
    
}

- (NSString *)catchParams:(NSDictionary *)params;

@end

@implementation RTBaseService
@synthesize apiSite = _apiSite;
@synthesize serviceID = _serviceID;

- (void) dealloc {
    [super dealloc];
}

// can be set only once, and serviceID should > 0
- (void)setServiceID:(RTServiceType)serviceID {
    if (serviceID == 0)
        return;

    if (_serviceID == 0)
        _serviceID = serviceID;
}

// default implements
- (NSURL *)buildGetURLWithMethod:(NSString *)methodName params:(NSDictionary *)params {
    NSString *url = [self.apiSite stringByAppendingFormat:@"/%@?%@", methodName, [self catchParams:params]];
    return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)buildPostURLWithMethod:(NSString *)methodName params:(NSDictionary *)params {
    return [NSURL URLWithString:[self.apiSite stringByAppendingFormat:@"/%@?", methodName]];
}

- (NSDictionary *)parse:(NSString *)response {
    NSDictionary *content = [response JSONValue];
    return content;
}

- (NSString *)catchParams:(NSDictionary *)params {
    NSMutableString *paramsString = [NSMutableString string];
    
    for (NSString *key in [params allKeys]) {
        NSString *format = [paramsString length] ? @"&%@=%@" : @"%@=%@";
        if (![[NSNull null] isEqual:[params objectForKey:key]] && 
            ![@"" isEqualToString:[params objectForKey:key]])
            [paramsString appendFormat:format, key, [params objectForKey:key]];
    }
    
    return paramsString;
}


@end
