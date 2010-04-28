//
//  NameValueCell.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NameValueCell : UITableViewCell {
	UILabel *name;
	UILabel *value;
}

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *value;

@end
