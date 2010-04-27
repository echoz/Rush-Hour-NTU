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
@end
