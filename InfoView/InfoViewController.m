//
//  InfoViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation InfoViewController

@synthesize tableView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	indexPathToLaunch = nil;
	about = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"About" ofType:@"plist"]] retain];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [about count];
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [[[about objectAtIndex:section] objectAtIndex:1] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[about objectAtIndex:section] objectAtIndex:0];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
	}
	
	
	if (([[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"url"]) || 
	([[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"video"])) {
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;		
	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.textLabel.text = [[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"name"];
	
	NSString *aboutValue = [[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"value"];
	
	if ([[[NSBundle mainBundle] infoDictionary] objectForKey:aboutValue] == nil) {
		cell.detailTextLabel.text = aboutValue;		
		
	} else {
		cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:aboutValue];		
		
	}
	return cell;
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ((alertView.title == @"External URL Launch") && ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])) {
		NSIndexPath *indexPath = indexPathToLaunch;
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"url"]]];
	}
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
	
	if ([[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"url"]) {

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"External URL Launch"
														message:[NSString stringWithFormat:@"Are you sure you want to launch\n%@\n in Mobile Safari?",[[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"url"]]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes",nil];
		[alert show];
		[alert release];
		
		[indexPathToLaunch release];
		indexPathToLaunch = [indexPath retain];
	} else if ([[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"video"]) {

		NSString *filestr = [[[[about objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] objectForKey:@"video"];
		
		NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[filestr stringByDeletingPathExtension] ofType:[filestr pathExtension]]];
		
		MPMoviePlayerController* theMovie = [[MPMoviePlayerController alloc] initWithContentURL:url];
		
		theMovie.scalingMode = MPMovieScalingModeAspectFill;
		theMovie.movieControlMode = MPMovieControlModeDefault;
		
		// Register for the playback finished notification
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(doneDemo:) name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];
		
		// Movie playback is asynchronous, so this method returns immediately.
		[theMovie play];
	}
}

// When the movie is done, release the controller.
-(void) doneDemo: (NSNotification*) aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
	
    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMoviePlayerPlaybackDidFinishNotification object: theMovie];
	
    // Release the movie instance created in playMovieAtURL:
    [theMovie release];
}

-(IBAction)close {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[about release];
	[tableView release];
    [super dealloc];
}


@end
