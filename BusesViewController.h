//
//  BusesViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 10/1/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JONTUBusEngine.h"

@interface BusesViewController : UITableViewController {
	NSArray *buses;
}
@property (nonatomic, retain) NSArray *buses;

@end
