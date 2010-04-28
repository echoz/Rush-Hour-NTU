//
//  StopAnnotation.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopAnnotation.h"


@implementation StopAnnotation
@synthesize stop;

-(CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coord;
	coord.latitude = [[stop lat] doubleValue];
	coord.longitude = [[stop lon] doubleValue];
	return coord;
}

-(NSString *)title {
	return [NSString stringWithFormat:@"%@ (%@)",[stop desc],[stop code]];
}

-(NSString *)subtitle {
	return [stop roadName];
}

-(void)dealloc {
	[stop release];
	[super dealloc];
}
@end
