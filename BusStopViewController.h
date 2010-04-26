//
//  BusStopViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JONTUBusEngine.h"
#import "BusETACell.h"

@interface BusStopViewController : UITableViewController {
	NSUInteger busstopid;
	JONTUBusStop *stop;
	NSArray *arrivals;
	
	IBOutlet UIBarButtonItem *refreshETA;
	
	BusETACell *etaCell;
}

@property (nonatomic, assign) IBOutlet BusETACell *etaCell;

@property (readwrite) NSUInteger busstopid;
-(IBAction)refreshETA;
@end
