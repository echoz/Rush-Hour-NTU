//
//  LocationManager.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "LocationManager.h"


@implementation LocationManager

@synthesize manager;

SYNTHESIZE_SINGLETON_FOR_CLASS(LocationManager);

-(id)init {
	if (self = [super init]) {
		manager = [[CLLocationManager alloc] init];
		NSLog(@"INIT");
	}
	return self;
}

-(void) dealloc {
	[manager release];
	[super dealloc];
}
@end
