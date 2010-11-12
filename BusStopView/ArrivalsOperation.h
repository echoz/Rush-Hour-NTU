//
//  ArrivalsOperation.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JONTUBusStop.h"
#import "JOIris.h"

@interface ArrivalsOperation : NSOperation {
	JONTUBusStop *stop;
	JOIris *iris;
	id delegate;
	BOOL irisquery;
	NSString *serviceNumber;
	BOOL cancel;
}
-(id)initWithStop:(JONTUBusStop *)bstop iris:(JOIris *)irs delegate:(id)dgate;
-(id)initWithStop:(JONTUBusStop *)bstop queryIris:(JOIris *) irs forSvcNumber:(NSString *)svcnumber delegate:(id)dgate;
@property (nonatomic, retain) JONTUBusStop *stop;
@property (nonatomic, retain) JOIris *iris;
@property (nonatomic, retain) id delegate;
@property (readwrite) BOOL irisquery;

@end
