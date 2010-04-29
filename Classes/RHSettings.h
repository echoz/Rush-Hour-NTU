//
//  RHSettings.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface RHSettings : NSObject {
	NSMutableDictionary *stash;
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(RHSettings);
@property (nonatomic, retain) NSMutableDictionary *stash;

-(void)readSettings;
-(void)saveSettings;
@end
