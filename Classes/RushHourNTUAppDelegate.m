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
#import "RHSettings.h"
#import "FlurryAPI.h"

#define CACH_FILE @"JONTUBusCore.cache"
#define FLURRY_API_KEY @""

@implementation RushHourNTUAppDelegate

@synthesize window;
@synthesize navigationController;

void uncaughtExceptionHandler(NSException *exception);

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after app launch
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAPI startSession:FLURRY_API_KEY];
	
	[FlurryAPI logEvent:@"APP_HIT"];
	
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	if ([self.navigationController.visibleViewController isKindOfClass:[RootViewController class]]) {

		RootViewController *root = (RootViewController *)[self.navigationController visibleViewController];
		if (root.updatingLocation) {
			NSLog(@"Stop timer from firing");
			[root doneLocationAndUpdate];
		}
	}
	
	[self saveState];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
}

-(void)saveState {
	NSLog(@"Writing to cache");
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:CACH_FILE];
	
	[JONTUBusEngine saveState:cachePath];
	
	[[RHSettings sharedRHSettings] saveSettings];	
	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	[self saveState];
}

void uncaughtExceptionHandler(NSException *exception) {
	[FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
} 

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

