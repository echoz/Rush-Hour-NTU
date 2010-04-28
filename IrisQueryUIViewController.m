//
//  IrisQueryUIViewController.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "IrisQueryUIViewController.h"
#import "JONTUBusStop.h"

@implementation IrisQueryUIViewController
@synthesize service, code, eta, next;

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
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction)close {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)askIris {
	NSDictionary *iriseta = [JONTUBusStop irisQueryForService:service.text atStop:code.text];
	if ([[[iriseta valueForKey:@"service"] lowercaseString] hasPrefix:@"invalid service"]) {
		eta.text = @"Invalid Service";
		next.text = @"";
		
	} else if ([[[iriseta valueForKey:@"eta"] lowercaseString] hasPrefix:@"not operating"]) {
		eta.text = @"Off Service";
		next.text = @"";
		
	} else {
		eta.text = [iriseta valueForKey:@"eta"];
		next.text = [iriseta valueForKey:@"subsequent"];
		
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
	[eta release];
	[next release];
	[service release];
	[code release];
    [super dealloc];
}


@end
