//
//  RootViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import "RootViewController.h"
#import "JONTUBusEngine.h"
#import "BusStopViewController.h"
#import "NSString+htmlentitiesaddition.h"
#import "JONTUBusStop+location.h"
#import "LocationManager.h"
#import "CacheOperation.h"
#import "RegexKitLite.h"
#import <QuartzCore/QuartzCore.h>
#import "IrisQueryUIViewController.h"
#import "RHSettings.h"
#import "StopTableViewCell.h"
#import "FlurryAPI.h"
#import "InfoViewController.h"

@implementation RootViewController

@synthesize currentLocation, refreshCache, savedSearchTerm, filteredContent, searchWasActive, actualContent, workQueue, settings, originalContent;
@synthesize progressLoad,refreshError, infoButton, updatingLocation;
#pragma mark -
#pragma mark View lifecycle

@synthesize appSettingsViewController;

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsViewController.delegate = self;
	}
	return appSettingsViewController;
}

- (IBAction)showSettingsModal:(id)sender {
	
	
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self.appSettingsViewController.showDoneButton = YES;
    [self presentModalViewController:aNavController animated:YES];
    [aNavController release];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
	
	// your code here to reconfigure the app for changed settings
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIButton *titleLabel = [UIButton buttonWithType:UIButtonTypeCustom];
	[titleLabel setTitle:@"Traversity" forState:UIControlStateNormal];
	titleLabel.frame = CGRectMake(0, 0, 100, 44);
	titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:19];
	titleLabel.titleLabel.shadowColor = [UIColor grayColor];
	titleLabel.titleLabel.shadowOffset = CGSizeMake(0, -1);
	titleLabel.showsTouchWhenHighlighted = YES;
	[titleLabel addTarget:self action:@selector(titleTap:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.titleView = titleLabel;
	
	lastUpdate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 20)];
	lastUpdate.backgroundColor = [UIColor clearColor];
	lastUpdate.textAlignment = UITextAlignmentCenter;
	lastUpdate.textColor = [UIColor whiteColor];
	lastUpdate.shadowColor = [UIColor grayColor];
	lastUpdate.shadowOffset = CGSizeMake(0, -1);
	lastUpdate.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
	lastUpdate.text = @"";
	
	spinner = [UIImage imageNamed:@"spinner.png"];
	spinnerFrame = 0;
	
	genericDisplay = [[UIBarButtonItem alloc] initWithCustomView:lastUpdate];
	
	self.toolbarItems = [NSArray arrayWithObjects:currentLocation,
						 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						 genericDisplay,
						 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						 settings,
						 nil];
	
	self.navigationItem.rightBarButtonItem = refreshCache;
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];	
	
	if (self.savedSearchTerm) {
		[self.searchDisplayController setActive:self.searchWasActive];
		[self.searchDisplayController.searchBar setText:savedSearchTerm];
		
		self.savedSearchTerm = nil;
	}
	self.tableView.scrollEnabled = YES;
	self.tableView.backgroundColor = [UIColor colorWithRed:0.930 green:0.927 blue:0.926 alpha:1.000];
	
	LocationManager *manager = [LocationManager sharedLocationManager];
	
	[manager.manager dismissHeadingCalibrationDisplay];
	[manager.manager setDelegate:self];
	[manager.manager setDesiredAccuracy:kCLLocationAccuracyBest];
	
	proximitySort = NO;
	fillingCache = NO;
	scheduleWatcher = NO;
	
	workQueue = [[NSOperationQueue alloc] init];
	
	if ([JONTUBusEngine sharedJONTUBusEngine].brandNew) {
		CacheOperation *fillCache = [[CacheOperation alloc] initWithDelegate:self];
		[self.workQueue addOperation:fillCache];
		[fillCache release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		lastUpdate.text = @"Updating cache...";	// comment for taking of default images
		fillingCache = YES;
/*		
		genericDisplay.customView = progressLoad;
		progressLoad.progress = 0.0;
*/		

	} else {
		[self freshen];		
	}
	
	[self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	
	BOOL veteran = [[[RHSettings sharedRHSettings].stash valueForKey:@"veteran"] boolValue];
	
	if (!veteran) {
		[self titleTap:nil];
		[[RHSettings sharedRHSettings].stash setValue:[NSNumber numberWithBool:YES] forKey:@"veteran"];
		[[RHSettings sharedRHSettings] saveSettings];
		UIAlertView *firstalert = [[UIAlertView alloc] initWithTitle:@"Welcome"
															 message:@"Traversity works by using data provided by NTU's internal shuttle bus tracking system.\n\n Check out the demo videos to learn more."
															delegate:nil
												   cancelButtonTitle:@"Ok" 
												   otherButtonTitles:nil];
		[firstalert show];
		[firstalert release];
	}
	
	[self.navigationItem.leftBarButtonItem addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
	
	self.filteredContent = [NSMutableArray arrayWithCapacity:0];
	animationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLocationProgress) userInfo:nil repeats:YES] retain];


}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.navigationItem.leftBarButtonItem) {
		if ([[change valueForKey:@"new"] isEqualToString:@"Done"]) {
			[self.navigationItem.rightBarButtonItem setEnabled:NO];
		} else {
			[self.navigationItem.rightBarButtonItem setEnabled:YES];
		}
	}
}

-(void)cacheLoadStartNotification:(id)object {
	progressTotal = [[object object] intValue];
	progressCurrent = 0;
}

-(void)cacheLoadEndNotification:(id)object {
	NSLog(@"cache end");
	[genericDisplay setCustomView:lastUpdate];
	progressLoad.progress = 1.0;
}

-(void)cacheLoadNotification:(id)object {
	NSLog(@"cache update %f",(progressCurrent+1)/ progressTotal);

	progressCurrent++;
	[self.progressLoad setProgress:progressCurrent/progressTotal];
}

-(void) titleTap:(id) sender {
	/*
	InfoViewController *modalView = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
	[self presentModalViewController:modalView animated:YES];
	[modalView release];
	 */
	
	[self showIrisQuery];
}

-(IBAction)showIrisQuery {
	IrisQueryUIViewController *modalView = [[IrisQueryUIViewController alloc] initWithNibName:@"IrisQueryUIViewController" bundle:nil];
	[self presentModalViewController:modalView animated:YES];
	[modalView release];
}

-(IBAction)useLocation {
		
	self.updatingLocation = YES;
	[animationTimer fire];	

	[FlurryAPI logEvent:@"LOCATION_USE"];

	[currentLocation setStyle:UIBarButtonItemStyleDone];
//	[currentLocation setTarget:self];
	[currentLocation setAction:@selector(stopLocation)];
	
	LocationManager *manager = [LocationManager sharedLocationManager];
	[manager.manager startUpdatingLocation];
	proximitySort = YES;
	[self.tableView reloadData];
	

}


-(void)stopLocation {
	
	[self doneLocationAndUpdate];

	[currentLocation setStyle:UIBarButtonItemStyleBordered];
//	[currentLocation setTarget:self];
	[currentLocation setAction:@selector(useLocation)];
	
	self.updatingLocation = NO;
	
	LocationManager *manager = [LocationManager sharedLocationManager];	
	[manager.manager stopUpdatingLocation];
	proximitySort = NO;
	[actualContent release];
	actualContent = nil;
	[self freshen];
		
}

-(void)updateLocationProgress {
	if (self.updatingLocation) {
		UIGraphicsBeginImageContext(CGSizeMake(19, 19));
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		
		CGContextClipToRect(currentContext, CGRectMake(0, 0, 19, 19));
		
		CGContextDrawImage(currentContext, CGRectMake(spinnerFrame*-19, 0, 190, 19), spinner.CGImage);
		
		UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();	
		
		[currentLocation setImage:viewImage];
		
		spinnerFrame++;
		if (spinnerFrame == 10) {
			spinnerFrame = 0;
		}		
	}
	
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 5.0)
    {
		[self doneLocationAndUpdate];
    }
}

-(void)doneLocationAndUpdate {
	self.updatingLocation = NO;

	[animationTimer invalidate];

	self.actualContent = [[actualContent sortedArrayUsingSelector:@selector(compareLocation:)] mutableCopy];
	
	[currentLocation setImage:[UIImage imageNamed:@"location.png"]];
	
	[self.tableView reloadData];
	
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
}

-(IBAction)refreshTheCache {
	if ([[UIDevice currentDevice] hostAvailable:@"campusbus.ntu.edu.sg"]) {
		self.navigationItem.rightBarButtonItem = refreshCache;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reload Cache" 
														message:@"Are you sure you want to reload the entire Shuttle Bus Database?" 
													   delegate:self 
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes",nil];
		[alert setDelegate:self];
		[alert show];
		[alert release];
	} else {
		[self showNetworkErrorAlert];
		[self reachabilityChanged];
	}
}

-(void)showNetworkErrorAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Traversity needs an active internet connection to reload the cache." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ((alertView.title == @"Reload Cache") && ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])) {
		
		if ([[UIDevice currentDevice] hostAvailable:@"campusbus.ntu.edu.sg"]) {
			NSLog(@"Refreshing Cache");
			[[JONTUBusEngine sharedJONTUBusEngine] setHoldCache:20];
			CacheOperation *fillCache = [[CacheOperation alloc] initWithDelegate:self];
			[self.workQueue addOperation:fillCache];
			[fillCache release];
			
			[[UIDevice currentDevice] scheduleReachabilityWatcher:self];
			scheduleWatcher = YES;

			lastUpdate.text = @"Updating cache...";	
			
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.75];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[self.tableView setAlpha:0.5];
			[self.tableView setScrollEnabled:NO];
			[self.tableView setAllowsSelection:NO];
			[UIView commitAnimations];		
			
		} else {
			[self showNetworkErrorAlert];
			[self reachabilityChanged];
		}
	}
}

-(void)engineStarted {
	[FlurryAPI logEvent:@"CACHE_FILL"];
	
	NSLog(@"Fill Cache complete");
	fillingCache = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.navigationItem.rightBarButtonItem = refreshCache;
	[[JONTUBusEngine sharedJONTUBusEngine] setHoldCache:-1];
	
	NSString *matchString = [[NSString alloc] initWithData:[[JONTUBusEngine sharedJONTUBusEngine] indexPageCache] encoding:NSASCIIStringEncoding];
	
	if ([matchString rangeOfString:@"Database Error"].location != NSNotFound) {
		[self promptForPossibleError];
	}
	[matchString release];
	[self freshen];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[self.tableView setAlpha:1];
	[self.tableView setScrollEnabled:YES];
	[self.tableView setAllowsSelection:YES];
	[UIView commitAnimations];		
	
}

-(void)promptForPossibleError {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NTU Web Services" message:@"There is a possiblity that NTU Web Services is down. If you do not see results/data and think that there should be, this is most likely the case. Do a cache refresh when everything is back up." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)reachabilityChanged {
	self.navigationItem.rightBarButtonItem = refreshError;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[workQueue cancelAllOperations];
	
	[self.tableView setAlpha:1];
	[self.tableView setScrollEnabled:YES];
	[self.tableView setAllowsSelection:YES];	
	
	if (scheduleWatcher) {
		[[UIDevice currentDevice] unscheduleReachabilityWatcher];
		scheduleWatcher = NO;
	}	
}

-(void)freshen {
	JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];	
	self.actualContent = [[engine stops] mutableCopy];
	self.originalContent = [[engine stops] copy];
	
	NSMutableArray *toremove = [NSMutableArray array];
	
	for (JONTUBusStop *stop in self.actualContent) {
		if ([favorites indexOfObject:[stop code]] != NSNotFound) {
			[toremove addObject:stop];
		}
	}
	[self.actualContent removeObjectsInArray:toremove];
		
	NSDateFormatter *f = [[NSDateFormatter alloc] init];
	[f setDateStyle:NSDateFormatterShortStyle];
	[f setTimeStyle:NSDateFormatterShortStyle];
	
	lastUpdate.text = [NSString stringWithFormat:@"Last updated: %@", [f stringFromDate:engine.lastGetIndexPage]]; // comment for taking of default images
	[f release];
	
	[self.tableView reloadData];
}



- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.toolbarHidden = NO;
	favorites = [[RHSettings sharedRHSettings].stash valueForKey:@"favorites"];
	if (!favorites)
		favorites = [[NSMutableArray arrayWithArray:0] retain];

	if ((!fillingCache) && !(proximitySort))
		[self freshen];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
	self.searchWasActive = [self.searchDisplayController isActive];
	self.savedSearchTerm = [self.searchDisplayController.searchBar text];
	[super viewDidDisappear:animated];
	
}


/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return 1;
	} else {
		return 2;		
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		return [self.filteredContent count];
	} else {
		switch (section) {
			case 0:
				return [favorites count];
			case 1:
				return [actualContent count];
			default:
				return 0;
		}
	}

//	return 0; // for taking of default images
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (tableView != self.searchDisplayController.searchResultsTableView) {	
		switch (section) {
			case 0:
				if ([favorites count] > 0) {
					return @"Favourites";
				} else {
					return @"";
				}
			case 1:
				return @"Stops";
			default:
				return @"";
		}
	} else {
		return @"";
	}

//	return @""; // for taking of default images
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    StopTableViewCell *cell = (StopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[StopTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stop-bg.png"]] autorelease];

		cell.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;		

		cell.contentView.opaque = YES;
		cell.detailTextLabel.opaque = YES;
		cell.textLabel.opaque = YES;
		cell.contentView.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		
    }
	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		
		cell.textLabel.text = [[[self.filteredContent objectAtIndex:indexPath.row] desc] removeHTMLEntities];
		cell.detailTextLabel.text = [[self.filteredContent objectAtIndex:indexPath.row] roadName];
		cell.tag = [[self.filteredContent objectAtIndex:indexPath.row] busstopid];
		
	} else {
		if (([favorites count] == 0) || (indexPath.section == 1)) {
			cell.textLabel.text = [[[actualContent objectAtIndex:indexPath.row] desc] removeHTMLEntities];
			cell.textLabel.clearsContextBeforeDrawing = YES;
			
			if (proximitySort) {
				CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[[[actualContent objectAtIndex:indexPath.row] lat] doubleValue] longitude:[[[actualContent objectAtIndex:indexPath.row] lon] doubleValue]];
				CLLocationDegrees dist = [[[[LocationManager sharedLocationManager] manager] location] distanceFromLocation:stopLocation];
				
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%.fm away", dist];
				[stopLocation release];
				
			} else {
				cell.detailTextLabel.text = [[actualContent objectAtIndex:indexPath.row] roadName];
				
			}
			
			cell.tag = [[actualContent objectAtIndex:indexPath.row] busstopid];
			cell.fav.image = [UIImage imageNamed:@"star-icon-dark.png"];
			cell.showsReorderControl = NO;				
		} else {
			JONTUBusStop *favstop = [[JONTUBusEngine sharedJONTUBusEngine] stopForCode:[favorites objectAtIndex:indexPath.row]];
			cell.textLabel.text = [[favstop desc] removeHTMLEntities];
			cell.detailTextLabel.text = [favstop roadName];
			cell.tag = [favstop busstopid];
			cell.fav.image = [UIImage imageNamed:@"star-icon-filled-dark.png"];
			cell.showsReorderControl = YES;
		}
	}
    
	// Configure the cell.	
	
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.backgroundColor = [UIColor clearColor];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Remove";
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {

		((StopTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).swipe = YES;
	}
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {

	[self.tableView setEditing:NO animated:NO];

	for (StopTableViewCell *cell in [self.tableView visibleCells]) {
		[cell setEditing:NO];
	}
	
//	if ([favorites count] == 0)
//		[tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] withRowAnimation:UITableViewRowAnimationNone];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 0) && ([favorites count] > 0)) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
	return UITableViewCellEditingStyleInsert;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger idtorestore = [self.tableView cellForRowAtIndexPath:indexPath].tag;
		
		for (int i=0;i<[originalContent count];i++) {
			if ([[originalContent objectAtIndex:i] busstopid] == idtorestore) {
				
				NSMutableDictionary *flurryparms = [NSMutableDictionary dictionary];
				[flurryparms setObject:((JONTUBusStop *)[originalContent objectAtIndex:i]).code forKey:@"stop-code"];
				
				[FlurryAPI logEvent:@"STOP_UNFAV" withParameters:flurryparms];

				[actualContent insertObject:[originalContent objectAtIndex:i] atIndex:i];
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:1]] 
								 withRowAnimation:UITableViewRowAnimationFade];

				[favorites removeObjectAtIndex:indexPath.row];			
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

				
				
				break;
			}
		}

		if ([favorites count] == 0) {
			[tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];			
		}
		
		[[RHSettings sharedRHSettings].stash setObject:favorites forKey:@"favorites"];
		[[RHSettings sharedRHSettings] saveSettings];
		
	}
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if ((fromIndexPath.section == 0) && (toIndexPath.section == 0)) {
		[favorites exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
		[[RHSettings sharedRHSettings].stash setObject:favorites forKey:@"favorites"];
		[[RHSettings sharedRHSettings] saveSettings];		
	}
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 0) && ([favorites count] > 0)) {
		return YES;
	} else {
		return NO;
	}
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.tableView.editing) && (indexPath.section == 1)) {
		StopTableViewCell *cell = (StopTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		cell.fav.image = [UIImage imageNamed:@"star-icon-filled-dark.png"];
		JONTUBusStop *stop = [[JONTUBusEngine sharedJONTUBusEngine] stopForId:cell.tag];
		
		[favorites addObject:stop.code];
		[actualContent removeObjectAtIndex:indexPath.row];

		NSMutableDictionary *flurryparms = [NSMutableDictionary dictionary];
		[flurryparms setObject:stop.code forKey:@"stop-code"];
		
		[FlurryAPI logEvent:@"STOP_FAV" withParameters:flurryparms];
		
		[tableView beginUpdates];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[favorites count]-1 inSection:0]]
						 withRowAnimation:UITableViewRowAnimationFade];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[tableView endUpdates];
		
		if ([favorites count] == 1)
			[tableView reloadSections:[[[NSIndexSet alloc] initWithIndex:0] autorelease] withRowAnimation:UITableViewRowAnimationFade];

		[[RHSettings sharedRHSettings].stash setObject:favorites forKey:@"favorites"];
		[[RHSettings sharedRHSettings] saveSettings];

		
	} else if (!self.tableView.editing) {
		
		BusStopViewController *detailViewController = [[BusStopViewController alloc] initWithNibName:@"BusStopViewController" bundle:nil];
		detailViewController.busstopid = [[tableView cellForRowAtIndexPath:indexPath] tag];
		
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
		
	}
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	[self.filteredContent removeAllObjects];
	
	for (JONTUBusStop *stop in originalContent) {
		
		NSRange descresult = [stop.desc rangeOfString:searchText options:NSCaseInsensitiveSearch];
		NSRange coderesult = [stop.code rangeOfString:searchText options:NSCaseInsensitiveSearch];
		NSRange roadnameresult = [stop.roadName rangeOfString:searchText options:NSCaseInsensitiveSearch];
		if ((coderesult.location != NSNotFound) || (descresult.location != NSNotFound) || (roadnameresult.location != NSNotFound)) {
			[self.filteredContent addObject:stop];
		}
		
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.filteredContent = nil;
	
}


- (void)dealloc {
	
	[appSettingsViewController release], appSettingsViewController = nil;

	[favorites release];
	[animationTimer release];
	[spinner release];
	[settings release];
	[workQueue release];
	[lastUpdate release];
	[refreshCache release];
	[actualContent release];
	[progressLoad release];
	[genericDisplay release];
	[savedSearchTerm release];
	[filteredContent release];
	[infoButton release];
	[currentLocation release];
	[super dealloc];
}


@end

