//
//  BusViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JONTUBus.h"
#import "JONTUBusEngine.h"
#import "JONTUBusStop.h"
#import "NameValueCell.h"

@interface BusViewController : UITableViewController <MKMapViewDelegate> {
	MKMapView *map;
	UITableViewCell *mapCell;
	JONTUBus *bus;
	JONTUBusStop *stop;
	MKPolyline *polyline;
	MKPolylineView *polylineView;
	
	NameValueCell *nvCell;
}
@property (nonatomic, retain) JONTUBus *bus;
@property (nonatomic, retain) JONTUBusStop *stop;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UITableViewCell *mapCell;
@property (nonatomic, assign) IBOutlet NameValueCell *nvCell;
@end
