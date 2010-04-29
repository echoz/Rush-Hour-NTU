//
//  RHSettings.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RHSettings.h"

#define SETTINGS_FILE @"Settings.plist"

@implementation RHSettings

@synthesize stash;

SYNTHESIZE_SINGLETON_FOR_CLASS(RHSettings);

-(id)init {
	if (self = [super init]) {
		[self readSettings];
	}
	return self;
}

- (void)readSettings {
	// Get Paths
	//	NSString *defaultSettingsPath = [[NSBundle mainBundle] pathForResource:@"DefaultSettings" ofType:@"plist"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *settingsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:SETTINGS_FILE];

	if ([[NSFileManager defaultManager] fileExistsAtPath:settingsPath]) {
		self.stash = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	} else {
		self.stash = [NSMutableDictionary dictionary];
	}
	
	/*	
	// Read in Default settings
	self.stash = [NSMutableDictionary dictionaryWithContentsOfFile:defaultSettingsPath];
	
	// Read in Current settings and merge
	NSDictionary *currentSettings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
	for (NSString *key in [currentSettings allKeys]) {
		if ([[self.stash allKeys] indexOfObject:key] != NSNotFound) {
			if (![[currentSettings objectForKey:key] isEqual:[self.stash objectForKey:key]]) {
				
				// Different so merge
				[self.stash setObject:[currentSettings objectForKey:key] forKey:key];
				
			}
		}
	}
	 */
	
}

- (void)saveSettings {
	if (self.stash) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *settingsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:SETTINGS_FILE];
		[self.stash writeToFile:settingsPath atomically:YES];
	}
}

-(void)dealloc {
	[stash release];
	[super dealloc];
}

@end
