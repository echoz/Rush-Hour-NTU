//
//  BusStopViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JONTUBusEngine.h"

@interface BusStopViewController : UITableViewController {
	NSUInteger busstopid;
	JONTUBusStop *stop;
	NSArray *arrivals;
}

@property (readwrite) NSUInteger busstopid;

@end
