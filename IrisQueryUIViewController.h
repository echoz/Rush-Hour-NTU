//
//  IrisQueryUIViewController.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IrisQueryUIViewController : UIViewController {
	UITextField *code;
	UITextField *service;
	UILabel *eta;
	UILabel *next;
}
@property (nonatomic, retain) IBOutlet UITextField *code;
@property (nonatomic, retain) IBOutlet UITextField *service;
@property (nonatomic, retain) IBOutlet UILabel *eta;
@property (nonatomic, retain) IBOutlet UILabel *next;
-(IBAction)askIris;
-(IBAction)close;
@end
