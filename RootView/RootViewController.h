//
//  RootViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIDevice-Reachability.h"

@interface RootViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, ReachabilityWatcher> {
	UIBarButtonItem *currentLocation;
	UIBarButtonItem *refreshCache;
	UIBarButtonItem *irisquery;
	UIBarButtonItem *genericDisplay;
	UIBarButtonItem *refreshError;
	UIBarButtonItem *infoButton;
	UILabel *lastUpdate;
	UIProgressView *progressLoad;
	float progressTotal;
	float progressCurrent;
	
	NSMutableArray *filteredContent;
	NSMutableArray *actualContent;
	NSArray *originalContent;
	NSString *savedSearchTerm;
	BOOL searchWasActive;
	
	BOOL proximitySort;
	BOOL fillingCache;
	BOOL scheduleWatcher;
	BOOL updatingLocation;
	
	NSOperationQueue *workQueue;
	NSTimer *animationTimer;
	UIImage *spinner;
	int spinnerFrame;
	
	NSMutableArray *favorites;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *currentLocation;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshCache;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshError;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *irisquery;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *infoButton;
@property (nonatomic, retain) IBOutlet UIProgressView *progressLoad;

@property (nonatomic, retain) NSMutableArray *filteredContent;
@property (nonatomic, retain) NSMutableArray *actualContent;
@property (nonatomic, retain) NSArray *originalContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, readonly) NSOperationQueue *workQueue;

@property (readwrite) BOOL updatingLocation;

-(IBAction)useLocation;
-(IBAction)refreshTheCache;
-(IBAction)showIrisQuery;

-(void) titleTap:(id) sender;

-(void)stopLocation;
-(void)doneLocationAndUpdate;
-(void)freshen;
-(void)showNetworkErrorAlert;

-(void)cacheLoadNotification:(id)object;
-(void)cacheLoadEndNotification:(id)object;																											 
-(void)cacheLoadStartNotification:(id)object;
-(void)promptForPossibleError;
@end
