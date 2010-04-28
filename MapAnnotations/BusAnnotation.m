//
//  BusAnnotation.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BusAnnotation.h"


@implementation BusAnnotation
@synthesize bus;


-(CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coord;
	coord.latitude = [[bus lat] doubleValue];
	coord.longitude = [[bus lon] doubleValue];
	return coord;
}

-(NSString *)title {
	return [bus busPlate];
}

-(NSString *)subtitle {
	return [NSString stringWithFormat:@"Route %@ doing %i km/h",[[bus route] name], [bus speed]];
}

-(void)dealloc {
	[bus release];
	[super dealloc];
}

@end
