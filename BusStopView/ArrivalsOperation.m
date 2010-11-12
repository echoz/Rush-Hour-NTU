//
//  ArrivalsOperation.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArrivalsOperation.h"
#import "JONTUBusEngine.h"
#import "RegexKitLite.h"

@implementation ArrivalsOperation
@synthesize stop, delegate, irisquery, iris;

-(id)initWithStop:(JONTUBusStop *)bstop iris:(JOIris *)irs delegate:(id)dgate {
	if (self = [super init]) {
		self.stop = bstop;
		self.iris = irs;
		self.delegate = dgate;
		self.irisquery = NO;
		serviceNumber = nil;
		cancel = NO;
	}
	return self;
}

-(id)initWithStop:(JONTUBusStop *)bstop queryIris:(JOIris *) irs forSvcNumber:(NSString *)svcnumber delegate:(id)dgate {
	if (self = [super init]) {
		self.iris = irs;
		self.stop = bstop;
		self.delegate = dgate;
		self.irisquery = YES;
		serviceNumber = [svcnumber retain];
		cancel = NO;
	}
	return self;	
}

-(void)cancel {
	cancel = YES;
}

-(void)main {
	
	if (irisquery) {
		NSArray *iriseta = [iris arrivalsForService:serviceNumber atBusStop:self.stop.code];
		
		NSDictionary *service = nil;
		
		for (NSDictionary *dict in iriseta) {
			if ([[[dict valueForKey:@"service"] stringByReplacingOccurrencesOfRegex:@"^0*" withString:@""] isEqualToString:[serviceNumber stringByReplacingOccurrencesOfRegex:@"^0*" withString:@""]]) {
				service = dict;
				break;
			}
		}

		if (!cancel)
			[delegate performSelectorOnMainThread:@selector(gotIrisResult:) withObject:service waitUntilDone:YES];
		
	} else {
		
		NSDictionary *irisbuses = [iris busesAtBusStop:self.stop.code];

		if (!cancel) 
			[delegate performSelectorOnMainThread:@selector(gotIrisBuses:) withObject:irisbuses waitUntilDone:YES];
		
		JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];
		[engine busesWithRefresh:YES];
		NSArray *arrivals = [stop arrivals];
		if (!cancel)
			[delegate performSelectorOnMainThread:@selector(gotArrivals:) withObject:arrivals waitUntilDone:YES];
		
	}
	
}

-(void)dealloc {
	[delegate release], delegate = nil;
	[serviceNumber release], serviceNumber = nil;
	[stop release], stop = nil;
	[iris release], iris = nil;
	[super dealloc];
}

@end
