//
//  StopTableViewCell.h
//  RushHourNTU
//
//  Created by Jeremy Foo on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StopTableViewCell : UITableViewCell {
	UIImageView *fav;
	
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, readonly, retain) UIImageView *fav;

@end
