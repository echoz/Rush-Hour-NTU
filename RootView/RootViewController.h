//
//  RootViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
	UIBarButtonItem *currentLocation;
	
	NSMutableArray *filteredContent;
	NSString *savedSearchTerm;
	BOOL searchWasActive;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *currentLocation;
@property (nonatomic, retain) NSMutableArray *filteredContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

-(IBAction)useLocation;

@end
