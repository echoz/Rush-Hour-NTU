//
//  BusViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BusViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BusAnnotation.h"
#import "StopAnnotation.h"

@implementation BusViewController
@synthesize map, mapCell, bus, stop, nvCell;

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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = [bus busPlate];
	[map.layer setCornerRadius:10.0];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 	[self.navigationController setToolbarHidden:YES animated:YES];

	BusAnnotation *busAnnote = [[BusAnnotation alloc] init];
	[busAnnote setBus:bus];
	
	StopAnnotation *stopAnnote = [[StopAnnotation alloc] init];
	[stopAnnote setStop:stop];

	[map addAnnotations:[NSArray arrayWithObjects:busAnnote, stopAnnote,nil]];
	[stopAnnote release];
	[busAnnote release];
	
	MKCoordinateRegion newRegion;
    newRegion.center.latitude = [[stop lat] doubleValue];
    newRegion.center.longitude = [[stop lon] doubleValue];
    newRegion.span.latitudeDelta = 0.0112872;
    newRegion.span.longitudeDelta = 0.0109863;
	[map setRegion:newRegion animated:YES];
 
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
 	[self.navigationController setToolbarHidden:NO animated:YES];

}
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

-(void)updateBusLocation {
	
}

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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 4;
		default:
			return 0;
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 180;
	} else if (indexPath.section == 1) {
		return 44;
	} else {
		return 44;
	}
	
}
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"";
		case 1:
			return @"Details";
		default:
			return @"";
	}
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
		return mapCell;
	} else if (indexPath.section == 1) {
		static NSString *MyIdentifier = @"cell";
		
		NameValueCell *cell = (NameValueCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"NameValueCell" owner:self options:nil];
			cell = nvCell;
			self.nvCell = nil;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		switch (indexPath.row) {
			case 0:
				cell.name.text = @"Plate Number";
				cell.value.text = [bus busPlate];
				break;
			case 1:
				cell.name.text = @"Route";
				cell.value.text = [[bus route] name];
				break;
			case 2:
				cell.name.text = @"Speed";
				cell.value.text = [NSString stringWithFormat:@"%i km/h",[bus speed]];
				break;
			case 3:
				cell.name.text = @"GPS";
				cell.value.text = [NSString stringWithFormat:@"%@, %@",[[bus lat] stringValue],[[bus lon] stringValue]];
				break;
		}
		
		return cell;
	} else {
		return nil;
	}
	
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}
*/

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


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString* annotationIdentifier = @"annotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!pinView) {
		// if an existing pin view was not available, create one
		MKPinAnnotationView* pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		pinView.animatesDrop = NO;
		pinView.canShowCallout = YES;
		
	} else {
		pinView.annotation = annotation;
	}

	if ([annotation isKindOfClass:[StopAnnotation class]]) {
		pinView.pinColor = MKPinAnnotationColorGreen;
	} else if ([annotation isKindOfClass:[BusAnnotation class]]) {
		pinView.pinColor = MKPinAnnotationColorRed;
	}
	
	return pinView;
	
}


- (void)dealloc {
	[nvCell release], nvCell = nil;
	[bus release], bus = nil;
	[stop release], stop = nil;
	[map release], map = nil;
	[mapCell release], mapCell = nil;
    [super dealloc];
}


@end

