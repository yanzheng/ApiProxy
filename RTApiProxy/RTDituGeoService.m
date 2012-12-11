//
//  RTDituGeoService.m
//  RTApiProxy
//
//  Created by yan zheng on 12-12-11.
//
//

#import "RTDituGeoService.h"

@implementation RTDituGeoService

- (id)init {
    self = [super init];
    if (self) {
        self.apiSite = @"http://ditu.google.com/";
    }
    return self;
}

@end
