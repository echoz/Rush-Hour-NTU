//
//  InfoViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"


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
	urlStore = nil;
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
		case 1:
			return 2;
		case 2:
			return 4;
		default:
			return 0;
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"About";
		case 1:
			return @"Credits";
		case 2:
			return @"Open Source";
		default:
			break;
	}
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Version";
				cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			case 1:
				cell.textLabel.text = @"URL";
				cell.detailTextLabel.text = @"the.ornyx.net/traversity";
				break;
		}		
	} else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Development";
				cell.detailTextLabel.text = @"Jeremy Foo";
				break;
			case 1:
				cell.textLabel.text = @"Graphics";
				cell.detailTextLabel.text = @"Ian Meyer";
				break;
		}		
	} else if (indexPath.section == 2) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Glyphish";
				cell.detailTextLabel.text = @"";
				break;
			case 1:
				cell.textLabel.text = @"JONTUBusCore";
				cell.detailTextLabel.text = @"";
				break;
			case 2:
				cell.textLabel.text = @"RegexKitLite";
				cell.detailTextLabel.text = @"";
				break;
			case 3:
				cell.textLabel.text = @"UIDevice Additions";
				cell.detailTextLabel.text = @"";
				break;
				
		}				
	}
	
	
	return cell;
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ((alertView.title == @"Open URL") && ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])) {
		[[UIApplication sharedApplication] openURL:urlStore];
	}
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
	[urlStore release];
	//	urlStore = [url retain];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Open URL"
													message:[NSString stringWithFormat:@"This action will quit Traversity and launch the %@ in Mobile Safari. Are you sure you want to do that?",[urlStore absoluteURL]]
												   delegate:self
										  cancelButtonTitle:@"No"
										  otherButtonTitles:@"Yes",nil];
	[alert show];
	[alert release];
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
	[tableView release];
    [super dealloc];
}


@end
