//
//  BusesViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 10/1/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "BusesViewController.h"
#import "JONTUBus.h"

@implementation BusesViewController
@synthesize buses;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	placemarks = [[NSMutableDictionary dictionaryWithCapacity:0] retain];

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.buses = [[JONTUBusEngine sharedJONTUBusEngine] buses];
	geocoders = [[NSMutableArray arrayWithCapacity:[self.buses count]] retain];
	
	JONTUBus *bus;
	for (int i=0;i<[self.buses count];i++) {
		bus = [self.buses objectAtIndex:i];
		
		MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake([[bus lat] doubleValue], [[bus lon] doubleValue])];
		geocoder.delegate = self;
		[geocoder start];
		
		[geocoders addObject:geocoder];
		[geocoder release];
		
	}
	
	[self.tableView reloadData];
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

    [super viewDidDisappear:animated];
	[geocoders release], geocoders = nil;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.buses count];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	NSUInteger idx = [geocoders indexOfObject:geocoder];
	
	[placemarks setObject:placemark forKey:[[buses objectAtIndex:idx] busPlate]];
	
	[self.tableView reloadData];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	NSLog(@"ERROR: %@", error);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }

	JONTUBus *bus = [buses objectAtIndex:indexPath.row];
	
	
    // Configure the cell...
	
	MKPlacemark *placemark = [placemarks objectForKey:bus.busPlate];
	
	if (placemark) {
		cell.textLabel.text = bus.busPlate;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%ikm/h near %@ - %@", bus.speed, [placemark thoroughfare], bus.route.name];
	} else {
		cell.textLabel.text = bus.busPlate;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%ikm/h)", bus.route.name, bus.speed];
		
	}
	
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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
}


- (void)dealloc {
	[placemarks release];
	[geocoders release], geocoders = nil;
	[buses release];
    [super dealloc];
}


@end

