//
//  AddViewController.h
//  FreeSMS
//
//  Created by Roman Slysh on 1/5/13.
//  Copyright (c) 2013 Roman Slysh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLiteManager.h"

@interface AddViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextField *phoneTextField;


- (IBAction)back:(id)sender;
- (IBAction)add:(id)sender;

@end
