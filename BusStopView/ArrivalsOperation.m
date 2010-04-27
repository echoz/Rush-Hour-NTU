//
//  ArrivalsOperation.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArrivalsOperation.h"
#import "JONTUBusEngine.h"

@implementation ArrivalsOperation
@synthesize stop, delegate, irisquery;

-(id)initWithStop:(JONTUBusStop *)bstop delegate:(id)dgate {
	if (self = [super init]) {
		self.stop = bstop;
		self.delegate = dgate;
		self.irisquery = NO;
		serviceNumber = nil;
	}
	return self;
}

-(id)initWithStop:(JONTUBusStop *)bstop queryIrisForSvcNumber:(NSString *)svcnumber delegate:(id)dgate {
	if (self = [super init]) {
		self.stop = bstop;
		self.delegate = dgate;
		self.irisquery = YES;
		serviceNumber = svcnumber; 
	}
	return self;	
}

-(void)main {
	
	if (irisquery) {
		NSDictionary *irisQueryResult = [stop irisQueryForService:serviceNumber];
		[delegate performSelectorOnMainThread:@selector(gotIrisResult:) withObject:irisQueryResult waitUntilDone:YES];
	} else {
		JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];
		[engine busesWithRefresh:YES];
		NSArray *arrivals = [stop arrivals];
		[delegate performSelectorOnMainThread:@selector(gotArrivals:) withObject:arrivals waitUntilDone:YES];
		
	}
	
}

-(void)dealloc {
	[delegate release];
	[serviceNumber release];
	[stop release];
	[super dealloc];
}

@end
