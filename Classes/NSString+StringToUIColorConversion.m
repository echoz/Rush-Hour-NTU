//
//  NSString+htmlentitiesaddition.m
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+StringToUIColorConversion.h"


@implementation NSString (StringToUIColorConversion)

#define HEXCOLOR(c) [UIColor colorWithRed:((c)&0xFF)/255.0 \
green:((c>>8)&0xFF)/255.0 \
blue:((c>>16)&0xFF)/255.0 \
alpha:1.0]

//alpha:((c>>24)&0xFF)/255.0]

-(UIColor *) UIColorValue {
	unsigned int colorValue;
	[[NSScanner scannerWithString:self] scanHexInt:&colorValue];
	return HEXCOLOR(colorValue);
}

@end
