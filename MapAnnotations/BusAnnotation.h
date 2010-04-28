//
//  BusAnnotation.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "JONTUBus.h"

@interface BusAnnotation : NSObject <MKAnnotation> {
	JONTUBus *bus;
}
@property (nonatomic, retain) JONTUBus *bus;
@end
