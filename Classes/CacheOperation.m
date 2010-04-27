//
//  CacheOperation.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CacheOperation.h"
#import "JONTUBusEngine.h"

@implementation CacheOperation

@synthesize delegate;

-(id)initWithDelegate:(id)dgate {
	if (self = [super init]) {
		self.delegate = dgate;
	}
	return self;
}

-(void)main {
	JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];
	[engine start];
	[delegate performSelectorOnMainThread:@selector(engineStarted) withObject:nil waitUntilDone:YES];
}

-(void)dealloc {
	[delegate release];
	[super dealloc];
}

@end
