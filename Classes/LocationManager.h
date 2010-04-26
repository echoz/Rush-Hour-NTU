//
//  LocationManager.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SynthesizeSingleton.h"

@interface LocationManager : NSObject {
	CLLocationManager *manager;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(LocationManager);

@property (nonatomic, retain) CLLocationManager *manager;

@end
