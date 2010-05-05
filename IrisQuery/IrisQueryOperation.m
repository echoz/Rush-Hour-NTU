//
//  IrisQueryOperation.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IrisQueryOperation.h"
#import "JONTUBusEngine.h"

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
	NSDictionary *iriseta = [JONTUBusStop irisQueryForService:serviceNumber atStop:busStopCode];

	if (!cancel)
		[delegate performSelectorOnMainThread:@selector(irisAnswers:) withObject:iriseta waitUntilDone:YES];
}

-(void)dealloc {
	[serviceNumber release];
	[busStopCode release];
	[delegate release];
	[super dealloc];
}

@end
