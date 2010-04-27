//
//  NSString+htmlentitiesaddition.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+htmlentitiesaddition.h"


@implementation NSString (JOHTMLEntitiesAddition)

-(NSString *)removeHTMLEntities {
    self = [self stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    self = [self stringByReplacingOccurrencesOfString:@"&Agrave;" withString:@"À" options:NSLiteralSearch range:NSMakeRange(0, [self length])];

	return self;
}

+(NSString *) formattedDateRelativeToNow:(NSDate *)date {
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
	[mdf release];
	
	NSUInteger dayDiff = (int)[midnight timeIntervalSinceNow] / (60*60*24);
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	
	switch(dayDiff) {
		case 0:
			[dateFormatter setDateFormat:@"'today, 'H'h'mm'm"]; break;
		case -1:
			[dateFormatter setDateFormat:@"'yesterday, 'H'h'mm'm"]; break;
		default:
			[dateFormatter setDateFormat:@"MMMM d, H'h'mm'm"];
	}
	
	return [dateFormatter stringFromDate:date];
}

@end
