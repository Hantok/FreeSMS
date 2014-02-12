//
//  ChatViewController.h
//
//  Created by Roman Slysh on 10/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "Contact.h"

@interface ChatViewController : UIViewController {
}

@property (strong, nonatomic) IBOutlet UITextField *sendMessageField;
@property (strong, nonatomic) IBOutlet UITextField *antibotText;
@property (strong, nonatomic) IBOutlet UIButton    *sendMessageButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *antibot;
@property (strong, nonatomic) IBOutlet UILabel     *smsCountLabel;
@property (strong, nonatomic) IBOutlet UIButton    *updateMe;
@property (strong, nonatomic) NSMutableArray       *messages;
@property (strong, nonatomic) Contact              *contact;

- (IBAction)sendMessage:(id)sender;
- (IBAction)updateMe:(id)sender;
- (IBAction)edit:(id)sender;

@end
