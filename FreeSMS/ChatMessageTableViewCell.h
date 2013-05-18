//
//  ChatMessageTableViewCell.h
//  SimpleSample-chat_users-ios
//
//  Created by Roman Slysh on 10/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageTableViewCell : UITableViewCell

@property (nonatomic, strong) UITextView  *message;
@property (nonatomic, strong) UILabel     *date;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end
