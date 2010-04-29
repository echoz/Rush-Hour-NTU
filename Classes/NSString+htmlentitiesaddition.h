//
//  NSString+htmlentitiesaddition.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (JOHTMLEntitiesAddition)
-(NSString *)removeHTMLEntities;
+(UIColor *) colorFromHexString:(NSString *)colorString;
@end
