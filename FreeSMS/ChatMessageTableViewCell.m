//
//  ChatMessageTableViewCell.m
//
//  Created by Roman Slysh on 10/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import "ChatMessageTableViewCell.h"

@implementation ChatMessageTableViewCell

@synthesize message;
@synthesize date;
@synthesize backgroundImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        date = [[UILabel alloc] init];
        [date setFrame:CGRectMake(10, 5, 300, 20)];
        [date setFont:[UIFont systemFontOfSize:11.0]];
        [date setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:date];
        
        backgroundImageView = [[UIImageView alloc] init];
        [backgroundImageView setFrame:CGRectZero];
		[self.contentView addSubview:backgroundImageView];
        
		message = [[UITextView alloc] init];
        [message setBackgroundColor:[UIColor clearColor]];
        [message setEditable:NO];
        [message setScrollEnabled:NO];
		[message sizeToFit];
		[self.contentView addSubview:message];
    }
    return self;
}

@end
