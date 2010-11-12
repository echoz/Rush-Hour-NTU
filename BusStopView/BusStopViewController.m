//
//  BusStopViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BusStopViewController.h"
#import "BusesViewController.h"
#import "ArrivalsOperation.h"
#import "BusViewController.h"
#import "NSString+htmlentitiesaddition.h"
#import "RHSettings.h"
#import "FlurryAPI.h"
#import <math.h>
#import "Friendly.h"

@implementation BusStopViewController

@synthesize busstopid, etaCell, stopLocation, refreshETA, star, navTitleView, navRoadName, navStopName, loadProgress, refreshError;
@synthesize arrivals,irisArrivals;
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
	[super viewDidLoad];

	JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];
	iris = [[JOIris alloc] initWithTimeout:10];
	
	stop = [[engine stopForId:self.busstopid] retain];
	stopLocation = [[CLLocation alloc] initWithLatitude:[[stop lat] doubleValue] longitude:[[stop lon] doubleValue]];
	
	arrivals = [[NSMutableArray arrayWithCapacity:0] retain];
	irisArrivals = [[NSMutableArray arrayWithCapacity:0] retain];
	workQueue = [[NSOperationQueue alloc] init];
	[workQueue setMaxConcurrentOperationCount:5];
	
	self.toolbarItems = [NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						 star,
						 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
						 nil];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[[stop desc] removeHTMLEntities] style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];		
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.navigationItem.rightBarButtonItem = refreshETA;
	
	//	self.title = [stop code];
	navStopName.text = [[stop desc] removeHTMLEntities];
	navRoadName.text = [stop roadName];
	self.navigationItem.titleView = navTitleView;
	
	self.loadProgress.alpha = 0.0;
	self.navRoadName.alpha = 1.0;
	
	scheduleWatcher = NO;
	
	NSMutableArray *favs = [[RHSettings sharedRHSettings].stash valueForKey:@"favorites"];
	if (!favs)
		favs = [NSMutableArray array];
	
	if ([favs indexOfObject:[stop code]] != NSNotFound) {
		[star setImage:[UIImage imageNamed:@"star-icon-filled.png"]];
	} else {
		[star setImage:[UIImage imageNamed:@"star-icon.png"]];
	}
	
	NSMutableDictionary *flurryparms = [NSMutableDictionary dictionary];
	[flurryparms setObject:[stop code] forKey:@"stop-code"];
	[FlurryAPI logEvent:@"STOP_HIT" withParameters:flurryparms];

	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= (float)4.2) {

		[self addObserver:self forKeyPath:@"irisArrivals" options:0 context:NULL];
		[self addObserver:self forKeyPath:@"arrivals" options:0 context:NULL];
	}	
	
	[self refresh];
}

-(void)gotArrivals:(id)object {
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= (float)4.2) {
		for (NSDictionary *bus in object) {
			[self willChangeValueForKey:@"arrivals"];
			[self insertObject:bus inArrivalsAtIndex:0];
		}
		
	} else {
		for (NSDictionary *bus in object) {
			[arrivals addObject:bus];
		}
		[self.tableView reloadData];
		
	}


	[self updateProgressBar];
}

-(void)gotIrisBuses:(id)object {
	
	ArrivalsOperation *arrivalsop = nil;
	NSArray *buses = nil;
	
	if (object) 
		buses = [object valueForKey:@"buses"];

	for (int i=0;i<[buses count];i++) {
		arrivalsop = [[ArrivalsOperation alloc] initWithStop:stop queryIris:iris forSvcNumber:[buses objectAtIndex:i] delegate:self];
		[workQueue addOperation:arrivalsop];
		totalOps++;
		[arrivalsop release], arrivalsop = nil;
	}
	
	[self updateProgressBar];
	
}

-(void)gotIrisResult:(id)object {
	if (object) {
		
//		NSLog(@"%@", ([[[UIDevice currentDevice] systemVersion] floatValue] >= (float)4.2)?@"YES":@"NO");
		
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= (float)4.2) {
			[self willChangeValueForKey:@"irisArrivals"];	
			[self insertObject:object inIrisArrivalsAtIndex:0];
			
		} else {
			[irisArrivals addObject:object];
			[self.tableView reloadData];
			
		}
		
	}

	[self updateProgressBar];
	
}

-(void)updateProgressBar {
	completedOps++;
	[self.loadProgress setProgress:((float)completedOps-1)/(float)totalOps];
	
	if (completedOps-1 == totalOps) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.75];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		self.loadProgress.alpha = 0.0;
		self.navRoadName.alpha = 1.0;
		[UIView commitAnimations];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		if (scheduleWatcher) {
			[[UIDevice currentDevice] unscheduleReachabilityWatcher];
			scheduleWatcher = NO;
		}
		self.navigationItem.rightBarButtonItem = refreshETA;
	}
}

- (NSUInteger)countOfArrivals {
    return [arrivals count];
}

- (id)objectInArrivalsAtIndex:(NSUInteger)idx {
    return [arrivals objectAtIndex:idx];
}

- (void)insertObject:(id)anObject inArrivalsAtIndex:(NSUInteger)idx {
    [arrivals insertObject:anObject atIndex:idx];
}

- (void)removeObjectFromArrivalsAtIndex:(NSUInteger)idx { 
    [arrivals removeObjectAtIndex:idx];
}

- (NSUInteger)countOfIrisArrivals {
    return [irisArrivals count];
}

- (id)objectInIrisArrivalsAtIndex:(NSUInteger)idx {
    return [irisArrivals objectAtIndex:idx];
}

- (void)insertObject:(id)anObject inIrisArrivalsAtIndex:(NSUInteger)idx {
    [irisArrivals insertObject:anObject atIndex:idx];
}

- (void)removeObjectFromIrisArrivalsAtIndex:(NSUInteger)idx { 
    [irisArrivals removeObjectAtIndex:idx];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	
    NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
    if (indices == nil)
        return; // Nothing to do
    
    
    // Build index paths from index sets
    NSUInteger indexCount = [indices count];
    NSUInteger buffer[indexCount];
    [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
	
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < indexCount; i++) {
        NSUInteger indexPathIndices[2];

		if ([keyPath isEqualToString:@"arrivals"]) {
			indexPathIndices[0] = 0;
			
		} else if ([keyPath isEqualToString:@"irisArrivals"]) {
			indexPathIndices[0] = 1;
			
		}
	
        indexPathIndices[1] = buffer[i];
        NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
        [indexPathArray addObject:newPath];
    }
    
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    if ([kind integerValue] == NSKeyValueChangeInsertion) { // Rows were added
		[self.tableView beginUpdates];
		if (([keyPath isEqualToString:@"arrivals"]) && (!shuttleSectionHeaderUpdate)) {
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			shuttleSectionHeaderUpdate = YES;
			
		} else if (([keyPath isEqualToString:@"irisArrivals"]) && (!busSectionHeaderUpdate)){
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
			busSectionHeaderUpdate = YES;
			
		}
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
		
	} else if ([kind integerValue] == NSKeyValueChangeRemoval) { // Rows were removed
		[self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];

		if (([keyPath isEqualToString:@"arrivals"]) && ([arrivals count] == 0)) {
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	
		} else if (([keyPath isEqualToString:@"irisArrivals"]) && ([irisArrivals count] == 0)){
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		}
		[self.tableView endUpdates];
	}
}

-(IBAction)favorite {
	NSMutableArray *favs = [[RHSettings sharedRHSettings].stash valueForKey:@"favorites"];
	if (!favs)
		favs = [NSMutableArray array];
	
	NSMutableDictionary *flurryparms = [NSMutableDictionary dictionary];
	[flurryparms setObject:[stop code] forKey:@"stop-code"];
	
	if ([favs indexOfObject:[stop code]] == NSNotFound) {
		[star setImage:[UIImage imageNamed:@"star-icon-filled.png"]];
		[favs addObject:[stop code]];
		[[RHSettings sharedRHSettings].stash setObject:favs forKey:@"favorites"];
		
		[FlurryAPI logEvent:@"STOP_FAV" withParameters:flurryparms];		
	} else {
		[star setImage:[UIImage imageNamed:@"star-icon.png"]];
		[favs removeObject:[stop code]];
		[[RHSettings sharedRHSettings].stash setObject:favs forKey:@"favorites"];
		
		[FlurryAPI logEvent:@"STOP_UNFAV" withParameters:flurryparms];
	}
	[[RHSettings sharedRHSettings] saveSettings];

}

-(IBAction)refresh {
	self.loadProgress.progress = 0;
	totalOps = 0;
	completedOps = 0;
	busSectionHeaderUpdate = NO;
	shuttleSectionHeaderUpdate = NO;
	
	if ([workQueue operations] > 0)
		[workQueue cancelAllOperations];
	
	if (([[UIDevice currentDevice] hostAvailable:@"campusbus.ntu.edu.sg"]) && ([[UIDevice currentDevice] hostAvailable:@"www.sbstransit.com.sg"])) {

		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= (float)4.2) {

			int arrivalCount = [arrivals count];		
			for (int i=0;i<arrivalCount;i++) {
				[self removeObjectFromArrivalsAtIndex:0];
			}
			
			int irisArrivalCount = [irisArrivals count];		
			for (int i=0;i<irisArrivalCount;i++) {
				[self removeObjectFromIrisArrivalsAtIndex:0];
			}
			
		} else {
			[irisArrivals removeAllObjects];
			[arrivals removeAllObjects];
			[self.tableView reloadData];			
		}		
		
		
		
		ArrivalsOperation *arrivalsop = [[ArrivalsOperation alloc] initWithStop:stop iris:iris delegate:self];
		[workQueue addOperation:arrivalsop];
		totalOps++;
		[arrivalsop release], arrivalsop = nil;
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		self.loadProgress.alpha = 1.0;
		self.navRoadName.alpha = 0.0;
		[[UIDevice currentDevice] scheduleReachabilityWatcher:self];
		scheduleWatcher = YES;
		self.navigationItem.rightBarButtonItem = refreshETA;
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"An active internet connection is needed to retrieve the latest bus timings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[self reachabilityChanged];
	}
	
}

-(void)reachabilityChanged {
	self.navigationItem.rightBarButtonItem = refreshError;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[workQueue cancelAllOperations];
	self.loadProgress.alpha = 0.0;
	self.navRoadName.alpha = 1.0;
	if (scheduleWatcher) {
		[[UIDevice currentDevice] unscheduleReachabilityWatcher];
		scheduleWatcher = NO;
	}	
}

- (void)viewDidAppear:(BOOL)animated {
	[self.navigationController setToolbarHidden:NO animated:YES];
	[super viewDidAppear:animated];	
}


- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationController setToolbarHidden:YES animated:YES];
	[super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
/*
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;		
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [arrivals count];
		case 1:
			return [irisArrivals count];				
	}
	return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			if ([arrivals count] > 0) {
				return @"Internal Shuttle";					
			} else {
				return @"";
			}
		case 1:
			if ([irisArrivals count] > 0) {
				return @"Public Transport";
			} else {
				return @"";
			}
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"cell";
	
    BusETACell *cell = (BusETACell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"BusETACell" owner:self options:nil];
		cell = etaCell;
		self.etaCell = nil;
		cell.detailLabel.highlightedTextColor = [UIColor whiteColor];
		cell.textLabel.highlightedTextColor = [UIColor whiteColor];
		cell.subtextLabel.highlightedTextColor = [UIColor whiteColor];		
    }
	
	
	if (indexPath.section == 0) {
		
		JONTUBusEngine *engine = [JONTUBusEngine sharedJONTUBusEngine];
		JONTUBus *bus = [engine busForPlate:[[arrivals objectAtIndex:indexPath.row] valueForKey:@"plate"]];
		
		CLLocation *busLocation = [[CLLocation alloc] initWithLatitude:[[bus lat] doubleValue] longitude:[[bus lon] doubleValue]];

		//cell.textLabel.textColor = [NSString colorFromHexString:[[engine routeForId:[[[arrivals objectAtIndex:indexPath.row] valueForKey:@"routeid"] integerValue]] color]];

		cell.textLabel.text = [[arrivals objectAtIndex:indexPath.row] valueForKey:@"routename"];
		cell.subtextLabel.text = [NSString stringWithFormat:@"%@ away (%ikm/h): %@", [Friendly distanceString:[stopLocation distanceFromLocation:busLocation]], [bus speed], [bus busPlate]];
		if ([[arrivals objectAtIndex:indexPath.row] valueForKey:@"err"]) {
			cell.detailLabel.text = @"";
			cell.subtextLabel.text = @"Not available";
		
		} else {
			cell.detailLabel.text = [[arrivals objectAtIndex:indexPath.row] valueForKey:@"eta"];		
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		[busLocation release];
	} else if (indexPath.section == 1) {
		
		NSDictionary *irisbus = [irisArrivals objectAtIndex:indexPath.row];
		
		cell.textLabel.text = [irisbus valueForKey:@"service"];
		
		if ([[[irisbus valueForKey:@"eta"] lowercaseString] hasPrefix:@"not operating"]) {
			cell.subtextLabel.text = [NSString stringWithFormat:@"Off Service"];
			cell.detailLabel.text = [irisbus valueForKey:@""];
			
		} else {
			cell.subtextLabel.text = [NSString stringWithFormat:@"Next bus: %@", [irisbus valueForKey:@"subsequent"]];
			cell.detailLabel.text = [irisbus valueForKey:@"eta"];
			
		}		
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
	}
		
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (indexPath.section == 0) {
		if ([[arrivals objectAtIndex:indexPath.row] valueForKey:@"err"]) {
			BusesViewController *busesView = [[BusesViewController alloc] initWithNibName:@"BusesViewController" bundle:nil];
			[self.navigationController pushViewController:busesView animated:YES];
			[busesView release];
		} else {
			JONTUBus *bus = [[JONTUBusEngine sharedJONTUBusEngine] busForPlate:[[arrivals objectAtIndex:indexPath.row] valueForKey:@"plate"]];			
			BusViewController *busView = [[BusViewController alloc] initWithNibName:@"BusViewController" bundle:nil];
			busView.bus = bus;
			busView.stop = stop;
			[self.navigationController pushViewController:busView animated:YES];
			[busView release];
			
		}
		
	}
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[navStopName release];
	[navRoadName release];
	[navTitleView release];
	[star release];
	[refreshETA release];
	[irisArrivals release];
	[stop release];
	[arrivals release];
	[stopLocation release];
	[etaCell release];
	[workQueue release];
	[iris release];
	[super dealloc];
}


@end

