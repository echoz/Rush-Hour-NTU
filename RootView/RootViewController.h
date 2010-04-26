//
//  RootViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
	UIBarButtonItem *currentLocation;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *currentLocation;

-(IBAction)useLocation;

@end
