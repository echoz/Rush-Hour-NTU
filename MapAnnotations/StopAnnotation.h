//
//  StopAnnotation.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "JONTUBusStop.h"

@interface StopAnnotation : NSObject <MKAnnotation> {
	JONTUBusStop *stop;
}

@property (nonatomic,retain) JONTUBusStop *stop;

@end
