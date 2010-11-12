//
//  IrisQueryOperation.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IrisQueryOperation.h"
#import "JOIris.h"
#import "RegexKitLite.h"

@implementation IrisQueryOperation

@synthesize delegate;

-(id)initWithServiceNumber:(NSString*)svcnumber stopCode:(NSString*)stopcode delegate:(id)dgate {
	if (self = [super init]) {
		self.delegate = dgate;
		serviceNumber = [svcnumber copy];
		busStopCode = [stopcode copy];
		cancel = NO;
	}
	return self;
}

-(void)cancel {
	cancel = YES;
}

-(void)main {
	JOIris *iris = [[JOIris alloc] initWithTimeout:10];
	
	NSArray *iriseta = [iris arrivalsForService:serviceNumber atBusStop:busStopCode];

	NSDictionary *service = nil;
	
	for (NSDictionary *dict in iriseta) {
		if ([[[dict valueForKey:@"service"] stringByReplacingOccurrencesOfRegex:@"^0*" withString:@""] isEqualToString:[serviceNumber stringByReplacingOccurrencesOfRegex:@"^0*" withString:@""]]) {
			service = dict;
			break;
		}
	}
	
	[iris release];

	if (!cancel)
		[delegate performSelectorOnMainThread:@selector(irisAnswers:) withObject:service waitUntilDone:YES];
}

-(void)dealloc {
	[serviceNumber release];
	[busStopCode release];
	[delegate release];
	[super dealloc];
}

@end
