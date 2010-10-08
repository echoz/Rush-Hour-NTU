//
//  BusesViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 10/1/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JONTUBusEngine.h"
#import <MapKit/MapKit.h>

@interface BusesViewController : UITableViewController <MKReverseGeocoderDelegate> {
	NSArray *buses;
	NSMutableDictionary *placemarks;
}
@property (nonatomic, retain) NSArray *buses;

@end
