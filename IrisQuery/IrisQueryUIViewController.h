//
//  IrisQueryUIViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IrisQueryUIViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UITableView *tableView;
	UITableViewCell *stopcode;
	UITableViewCell *servicenumber;
	UITableViewCell *result;
	UITableViewCell *query;	
	
	UITextField *stopcodeText;
	UITextField *servicenumberText;
	
	UINavigationBar *navBar;
	
	UILabel *eta;
	UILabel *next;
	UIButton *queryButton;
	
	NSOperationQueue *workQueue;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *stopcode;
@property (nonatomic, retain) IBOutlet UITableViewCell *servicenumber;
@property (nonatomic, retain) IBOutlet UITableViewCell *result;
@property (nonatomic, retain) IBOutlet UITableViewCell *query;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UILabel *eta;
@property (nonatomic, retain) IBOutlet UILabel *next;
@property (nonatomic, retain) IBOutlet UITextField *stopcodeText;
@property (nonatomic, retain) IBOutlet UITextField *servicenumberText;

-(IBAction)close;
-(void)irisAnswers:(NSDictionary *)iriseta;
@end
