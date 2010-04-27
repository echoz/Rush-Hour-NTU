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

#define CACH_FILE @"JONTUBusCore.cache"

@implementation RushHourNTUAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after app launch
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:CACH_FILE];
		
	if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
		NSLog(@"Loading from cache");
		[JONTUBusEngine loadState:cachePath];		
	} 
	
	JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];
	
	[engine setHoldCache:-1];

	if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
		NSLog(@"No cache load");
		//		[engine start];
	}

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	NSLog(@"Writing to cache");
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:CACH_FILE];

	[JONTUBusEngine saveState:cachePath];

}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

