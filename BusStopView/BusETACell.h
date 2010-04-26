//
//  BusETACell.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BusETACell : UITableViewCell {
	UILabel *textLabel;
	UILabel *detailLabel;
	UILabel *subtextLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtextLabel;
@end
