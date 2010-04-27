//
//  RootViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate, UIAlertViewDelegate> {
	UIBarButtonItem *currentLocation;
	UIBarButtonItem *refreshCache;
	UIActivityIndicatorView *activity;
	UILabel *lastUpdate;
	
	NSMutableArray *filteredContent;
	NSMutableArray *actualContent;
	NSString *savedSearchTerm;
	BOOL searchWasActive;
	
	BOOL proximitySort;
	
	NSOperationQueue *workQueue;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *currentLocation;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshCache;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, retain) NSMutableArray *filteredContent;
@property (nonatomic, retain) NSMutableArray *actualContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, readonly) NSOperationQueue *workQueue;

-(IBAction)useLocation;
-(IBAction)refreshTheCache;

-(void)stopLocation;
-(void)freshen;

@end
