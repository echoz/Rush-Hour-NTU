//
//  IrisQueryUIViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "IrisQueryUIViewController.h"
#import "JONTUBusStop.h"
#import "FlurryAPI.h"
#import <QuartzCore/QuartzCore.h>
#import "IrisQueryOperation.h"

@implementation IrisQueryUIViewController
@synthesize tableView, stopcode, servicenumber, result, eta, next, query, navBar, stopcodeText, servicenumberText;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	[FlurryAPI logEvent:@"IRISQUERY_HIT"];
	eta.text = @"";
	next.text = @"";

	UIImageView *buttonBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"querybutton-bg.png"]];
	[buttonBG.layer setMasksToBounds:YES];
	[buttonBG.layer setCornerRadius:10.0];
	
	[query setBackgroundView:buttonBG];
	[buttonBG release];
	
	buttonBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"querybutton-bg-on.png"]];
	[buttonBG.layer setMasksToBounds:YES];
	[buttonBG.layer setCornerRadius:10.0];

	[query setSelectedBackgroundView:buttonBG];
	[buttonBG release];
	
	workQueue = [[NSOperationQueue alloc] init];
	[workQueue setMaxConcurrentOperationCount:1];
	
	hasResult = NO;
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)irisAnswers:(NSDictionary *)iriseta {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	hasResult = YES;
	if ([[[iriseta valueForKey:@"service"] lowercaseString] hasPrefix:@"invalid service"]) {
		eta.text = [NSString stringWithFormat:@"%@",servicenumberText.text];
		next.text = @"Invalid service";
		
	} else if ([[[iriseta valueForKey:@"eta"] lowercaseString] hasPrefix:@"not operating"]) {
		eta.text = [NSString stringWithFormat:@"%@",servicenumberText.text];
		next.text = @"Off Service";
		
	} else if (([[iriseta valueForKey:@"eta"] length] == 0) && ([[iriseta valueForKey:@"subsequent"] length] == 0)) {
		eta.text = [NSString stringWithFormat:@"Service %@",servicenumberText.text];
		next.text = @"Does not exist in IRIS database";
		
	} else {
		if ([[[iriseta valueForKey:@"eta"] lowercaseString] hasPrefix:@"arriving"]) {
			eta.text = [NSString stringWithFormat:@"%@ is arriving",servicenumberText.text];			
		} else {
			eta.text = [NSString stringWithFormat:@"%@ is arriving in %@",servicenumberText.text, [iriseta valueForKey:@"eta"]];			
		}
		
		if ([[[iriseta valueForKey:@"eta"] lowercaseString] hasPrefix:@"arriving"]) {
			next.text = @"The next bus is arriving";			
		} else {
			next.text = [NSString stringWithFormat:@"The next bus is arriving in %@", [iriseta valueForKey:@"subsequent"]];			
		}
	}
	[self.tableView reloadData];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (self.tableView.frame.size.height == 416.0) {
		[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 200)];
	}
	
	if (textField == stopcodeText) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	} else {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 416)];
	[textField resignFirstResponder];
	[self beginQuery];
	return NO;
}

-(IBAction)close {
	[self dismissModalViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return 60;
		default:
			return 44;
	}
	
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			if (hasResult) {
				return @"Result";				
			} else {
				return @"";
			}
		case 1:
			return @"Parameters";
		default:
			return @"";
	}
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			if (hasResult) {
				return 1;				
			} else {
				return 0;
			}
		case 1:
			return 2;
		case 2:
			return 1;

		default:
			return 0;
	}
	
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;

	switch (indexPath.section) {
		case 0:
			cell = result;
			break;
			
		case 1:
			if (indexPath.row == 0) {
				cell = stopcode;
			} else {
				cell = servicenumber;
			}
			break;
			
		case 2:
			cell = query;
			break;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath == [NSIndexPath indexPathForRow:0 inSection:2]) {
		[[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
		[self textFieldShouldReturn:servicenumberText];
	}
}

-(void)beginQuery {
	if (([servicenumberText.text length] > 0) && ([stopcodeText.text length] > 0)) {
		IrisQueryOperation *op = [[IrisQueryOperation alloc] initWithServiceNumber:servicenumberText.text stopCode:stopcodeText.text delegate:self];
		[workQueue addOperation:op];
		[op release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;			
	} else {
		[servicenumberText setSelected:YES];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[workQueue release];
	[tableView release];
	[eta release];
	[next release];
	[result release];
	[servicenumber release];
	[stopcode release];
	[query release];
	[stopcodeText release];
	[servicenumberText release];
	[navBar release];
	[queryButton release];
    [super dealloc];
}


@end
