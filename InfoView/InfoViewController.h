//
//  InfoViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
}

@property (nonatomic, retain) UITableView *tableView;
-(IBAction)close;
@end
