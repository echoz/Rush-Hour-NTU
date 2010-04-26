//
//  JONTUBusStop+location.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "JONTUBusStop.h"

@interface JONTUBusStop (JONTUBusStopLocationAdditions)
-(NSComparisonResult)compareLocation:(JONTUBusStop *)stop;
@end
