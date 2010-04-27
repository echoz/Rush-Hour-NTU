//
//  RushHourNTUAppDelegate.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/25/10.
//  Copyright ORNYX 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RushHourNTUAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@end

