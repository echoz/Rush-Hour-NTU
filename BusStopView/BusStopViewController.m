//
//  BusStopViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BusStopViewController.h"
#import "ArrivalsOperation.h"
#import "BusViewController.h"

@implementation BusStopViewController

@synthesize busstopid, etaCell, stopLocation, refreshETA, star;

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
	
	stop = [[engine stopForId:self.busstopid] retain];
	stopLocation = [[CLLocation alloc] initWithLatitude:[[stop lat] doubleValue] longitude:[[stop lon] doubleValue]];
	
	arrivals = nil;
	irisArrivals = [[NSMutableArray arrayWithCapacity:[[stop otherBus] count]] retain];
	workQueue = [[NSOperationQueue alloc] init];
	[workQueue setMaxConcurrentOperationCount:1];
	
	self.toolbarItems = [NSArray arrayWithObject:star];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.navigationItem.rightBarButtonItem = refreshETA;
	self.title = [stop code];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.navigationController.toolbarHidden = NO;

}

-(void)gotArrivals:(id)object {
	[arrivals release];
	arrivals = [object retain];
	if ([[workQueue operations] count] == 1) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
	
	[self.tableView reloadData];
}

-(void)gotIrisResult:(id)object {
	[irisArrivals addObject:object];
	if ([[workQueue operations] count] == 1) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
	
	[self.tableView reloadData];
}

-(IBAction)favorite {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Future action" message:@"To be implemented. Enjoy this alert for now." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(IBAction)refresh {
	if ([workQueue operations] > 0)
		[workQueue cancelAllOperations];
	
	ArrivalsOperation *arrivalsop = [[ArrivalsOperation alloc] initWithStop:stop delegate:self];
	[workQueue addOperation:arrivalsop];
	[arrivalsop release];
	arrivalsop = nil;
	
	[irisArrivals removeAllObjects];
	
	for (int i=0;i<[[stop otherBus] count];i++) {
		arrivalsop = [[ArrivalsOperation alloc] initWithStop:stop queryIrisForSvcNumber:[[stop otherBus] objectAtIndex:i] delegate:self];
		[workQueue addOperation:arrivalsop];
		[arrivalsop release];
		arrivalsop = nil;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refresh];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
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
	if ([[stop otherBus] count] > 0) {
		return 2;		
	} else {
		return 1;
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [arrivals count];
		case 1:
			if ([irisArrivals count] == [[stop otherBus] count]) {
				return [[stop otherBus] count];				
			}
	}
	return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([[stop otherBus] count] > 0) {
		switch (section) {
			case 0:
				return @"Internal Shuttle";
			case 1:
				return @"Public Transport";
		}
	}
	return @"Internal Shuttle";
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
				
		cell.textLabel.text = [[arrivals objectAtIndex:indexPath.row] valueForKey:@"routename"];
		cell.subtextLabel.text = [NSString stringWithFormat:@"%.0fm away (%ikm/h): %@", [stopLocation getDistanceFrom:busLocation], [bus speed], [bus busPlate]];
		if ([[arrivals objectAtIndex:indexPath.row] valueForKey:@"err"]) {
			cell.detailLabel.text = @"";
			cell.subtextLabel.text = @"Off Service";
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		} else {
			cell.detailLabel.text = [[arrivals objectAtIndex:indexPath.row] valueForKey:@"eta"];		
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		[busLocation release];
	} else if (indexPath.section == 1) {
		// need to fix invalid service thing here.
		
		if ([[[[irisArrivals objectAtIndex:indexPath.row] valueForKey:@"service"] lowercaseString] hasPrefix:@"invalid service"]) {
			cell.textLabel.text = [[stop otherBus] objectAtIndex:indexPath.row];
			cell.subtextLabel.text = @"Invalid Service";
			cell.detailLabel.text = @"";
			
		} else if ([[[[irisArrivals objectAtIndex:indexPath.row] valueForKey:@"eta"] lowercaseString] hasPrefix:@"not operating"]) {
			cell.textLabel.text = [[stop otherBus] objectAtIndex:indexPath.row];
			cell.subtextLabel.text = @"Off Service";
			cell.detailLabel.text = @"";
			
		} else {
			cell.textLabel.text = [[stop otherBus] objectAtIndex:indexPath.row];
			cell.subtextLabel.text = [NSString stringWithFormat:@"Next bus: %@", [[irisArrivals objectAtIndex:indexPath.row] valueForKey:@"subsequent"]];
			cell.detailLabel.text = [[irisArrivals objectAtIndex:indexPath.row] valueForKey:@"eta"];
			
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
		if (![[arrivals objectAtIndex:indexPath.row] valueForKey:@"err"]) {
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
	[star release];
	[refreshETA release];
	[irisArrivals release];
	[stop release];
	[arrivals release];
	[stopLocation release];
	[etaCell release];
	[workQueue release];
	[super dealloc];
}


@end

