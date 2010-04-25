//
//  RushHourNTUAppDelegate.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import "RushHourNTUAppDelegate.h"
#import "RootViewController.h"
#import "JONTUBusEngine.h"


@implementation RushHourNTUAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after app launch    
	JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];
	[engine setHoldCache:-1];
	[engine start];
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

