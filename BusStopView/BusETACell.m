//
//  BusETACell.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BusETACell.h"


@implementation BusETACell

@synthesize textLabel, detailLabel, subtextLabel;

- (void)dealloc {
	[textLabel release];
	[detailLabel release];
	[subtextLabel release];
    [super dealloc];
}


@end
