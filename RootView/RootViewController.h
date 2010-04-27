//
//  RootViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate> {
	UIBarButtonItem *currentLocation;
	UIActivityIndicatorView *activity;
	
	NSMutableArray *filteredContent;
	NSMutableArray *actualContent;
	NSString *savedSearchTerm;
	BOOL searchWasActive;
	
	BOOL proximitySort;
	
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *currentLocation;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, retain) NSMutableArray *filteredContent;
@property (nonatomic, retain) NSMutableArray *actualContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

-(IBAction)useLocation;
-(void)stopLocation;

-(void)freshen;

@end
