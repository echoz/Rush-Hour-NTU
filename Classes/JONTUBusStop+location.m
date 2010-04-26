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
	CLLocation *selfLocation = [[CLLocation alloc] initWithLatitude:[[self lat] doubleValue] longitude:[[self lon] doubleValue]];
	CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:[[stop lat] doubleValue] longitude:[[stop lon] doubleValue]];
	
	NSComparisonResult togo;
/*
	NSLog(@"%@", manager.location);
	NSLog(@"%@ / %@", selfLocation, otherLocation);
*/	

	if ([manager.manager.location getDistanceFrom:selfLocation] < [manager.manager.location getDistanceFrom:otherLocation]) {
		togo = NSOrderedAscending;
	} else if ([manager.manager.location getDistanceFrom:selfLocation] > [manager.manager.location getDistanceFrom:otherLocation]) {
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
