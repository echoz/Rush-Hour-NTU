//
//  IrisQueryOperation.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IrisQueryOperation : NSOperation {
	id delegate;
	BOOL cancel;
	NSString *serviceNumber;
	NSString *busStopCode;
}

@property (nonatomic, retain) id delegate;
-(id)initWithServiceNumber:(NSString*)svcnumber stopCode:(NSString*)stopcode delegate:(id)dgate;

@end
