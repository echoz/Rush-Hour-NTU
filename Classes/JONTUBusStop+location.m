//
//  JONTUBusStop+location.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "JONTUBusStop+location.h"
#import "LocationManager.h"

@implementation JONTUBusStop (JONTUBusStopLocationAdditions)
-(NSComparisonResult)compareLocation:(JONTUBusStop *)stop {
	LocationManager *manager = [LocationManager sharedLocationManager];
#if TARGET_IPHONE_SIMULATOR
//	CLLocation *selfLocation = [[CLLocation alloc] initWithLatitude:1.348034 longitude:103.680655]; // Lee Wee Nam Library
	CLLocation *selfLocation = [[CLLocation alloc] initWithLatitude:1.337748 longitude:103.696829]; // Pioneer MRT
#else
	CLLocation *selfLocation = [[CLLocation alloc] initWithLatitude:[[self lat] doubleValue] longitude:[[self lon] doubleValue]];	
#endif
	
	CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:[[stop lat] doubleValue] longitude:[[stop lon] doubleValue]];
	
	NSComparisonResult togo;
/*
	NSLog(@"%@", manager.location);
	NSLog(@"%@ / %@", selfLocation, otherLocation);
*/	

	if ([manager.manager.location distanceFromLocation:selfLocation] < [manager.manager.location distanceFromLocation:otherLocation]) {
		togo = NSOrderedAscending;
	} else if ([manager.manager.location distanceFromLocation:selfLocation] > [manager.manager.location distanceFromLocation:otherLocation]) {
		togo = NSOrderedDescending;
	} else {
		togo = NSOrderedSame;
	}
//	NSLog(@"%.0fm vs %.0fm = %@", [manager.manager.location getDistanceFrom:selfLocation] , [manager.manager.location getDistanceFrom:otherLocation],togo);

	
	[selfLocation release];
	[otherLocation release];
	return togo;
}
@end
