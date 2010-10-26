//
//  Friendly.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 10/26/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Friendly : NSObject {

}

+(NSString *) distanceString:(CLLocationDistance)dist;

@end
