//
//  Friendly.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 10/26/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "Friendly.h"


@implementation Friendly

-(id)init {
	return nil;
}

+(NSString *) distanceString:(CLLocationDistance)dist {
	if ((int)(dist/1000) > 0) {
		return [NSString stringWithFormat:@"%.1fkm", dist/1000];
	} else if ((int)(dist/100) > 4) {
		return [NSString stringWithFormat:@"%.2fkm", dist/1000];	
	} else {
		return [NSString stringWithFormat:@"%.0fm", dist];
	}
}

@end
