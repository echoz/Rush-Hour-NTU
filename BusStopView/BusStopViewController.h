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
#import "JOIris.h"

@interface BusStopViewController : UITableViewController <ReachabilityWatcher> {
	NSUInteger busstopid;
	JONTUBusStop *stop;
	NSMutableArray *arrivals;
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
	
	JOIris *iris;
	
	NSOperationQueue *workQueue;
	int totalOps;
	int completedOps;
	
	BOOL scheduleWatcher;

	BOOL shuttleSectionHeaderUpdate;
	BOOL busSectionHeaderUpdate;
}
@property (readonly) NSMutableArray *arrivals;
@property (readonly) NSMutableArray *irisArrivals;
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
-(void)updateProgressBar;
-(IBAction)refresh;
-(IBAction)favorite;

// KVO - array accessors
- (id)objectInArrivalsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inArrivalsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromArrivalsAtIndex:(NSUInteger)idx;

- (id)objectInIrisArrivalsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inIrisArrivalsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromIrisArrivalsAtIndex:(NSUInteger)idx;
@end
