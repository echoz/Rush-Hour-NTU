//
//  InfoViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameValueCell.h"


@interface InfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	UITableView *tableView;
	NSArray *about;
	NSIndexPath *indexPathToLaunch;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
-(IBAction)close;
@end
