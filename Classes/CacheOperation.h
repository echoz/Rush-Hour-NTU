//
//  CacheOperation.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CacheOperation : NSOperation {
	id delegate;
	BOOL cancel;
}

@property (nonatomic, retain) id delegate;
-(id)initWithDelegate:(id)dgate;
@end
