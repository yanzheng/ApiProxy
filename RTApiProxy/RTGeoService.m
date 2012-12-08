//
//  RTGeoService.m
//  RTNetwork
//
//  Created by Anjuke on 3/8/12.
//  Copyright (c) 2012 anjuke.inc. All rights reserved.
//

#import "RTGeoService.h"

@implementation RTGeoService

- (id)init {
    self = [super init];
    if (self) {
        self.apiSite = @"http://maps.googleapis.com/";
    }
    return self;
}

@end
