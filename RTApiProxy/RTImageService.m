//
//  RTImageService.m
//  RTNetwork
//
//  Created by yanzheng on 3/5/12.
//  Copyright (c) 2012 anjuke inc. All rights reserved.
//

#import "RTImageService.h"

@implementation RTImageService

- (id)init {
    self = [super init];
    if (self) {
        self.apiSite = @"";     // fetch image directly use the input param: url
    }
    return self;
}


@end
