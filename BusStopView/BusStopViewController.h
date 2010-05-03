//
//  BusStopViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JONTUBusEngine.h"
#import "JONTUBus.h"
#import "BusETACell.h"
#import <CoreLocation/CoreLocation.h>
#import "UIDevice-Reachability.h"

@interface BusStopViewController : UITableViewController <ReachabilityWatcher> {
	NSUInteger busstopid;
	JONTUBusStop *stop;
	NSArray *arrivals;
	NSMutableArray *irisArrivals;
	CLLocation *stopLocation;
	
	UIBarButtonItem *refreshETA;
	UIBarButtonItem *refreshError;
	UIBarButtonItem *star;
	UIView *navTitleView;
	UILabel *navStopName;
	UILabel *navRoadName;
	UIProgressView *loadProgress;
	
	BusETACell *etaCell;
	
	NSOperationQueue *workQueue;
	int totalOps;
	
	BOOL scheduleWatcher;
}
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshETA;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshError;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *star;
@property (nonatomic, retain) IBOutlet UIView *navTitleView;
@property (nonatomic, retain) IBOutlet UILabel *navStopName;
@property (nonatomic, retain) IBOutlet UILabel *navRoadName;
@property (nonatomic, retain) IBOutlet UIProgressView *loadProgress;
@property (nonatomic, assign) IBOutlet BusETACell *etaCell;
@property (readonly) CLLocation *stopLocation;
@property (readwrite) NSUInteger busstopid;
-(NSDictionary *)irisArrivalFromService:(NSString *)service;
-(void)updateProgressBar;
-(IBAction)refresh;
-(IBAction)favorite;
@end
