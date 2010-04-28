//
//  NameValueCell.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NameValueCell.h"


@implementation NameValueCell

@synthesize name, value;

- (void)dealloc {
	[name release];
	[value release];
    [super dealloc];
}


@end
