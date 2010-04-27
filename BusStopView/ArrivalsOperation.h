//
//  ArrivalsOperation.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JONTUBusStop.h"

@interface ArrivalsOperation : NSOperation {
	JONTUBusStop *stop;
	id delegate;
	BOOL irisquery;
	NSString *serviceNumber;
}
-(id)initWithStop:(JONTUBusStop *)bstop delegate:(id)dgate;
-(id)initWithStop:(JONTUBusStop *)bstop queryIrisForSvcNumber:(NSString *)svcnumber delegate:(id)dgate;
@property (nonatomic, retain) JONTUBusStop *stop;
@property (nonatomic, retain) id delegate;
@property (readwrite) BOOL irisquery;

@end
