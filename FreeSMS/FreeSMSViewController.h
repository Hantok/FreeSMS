//
//  FreeSMSViewController.h
//  FreeSMS
//
//  Created by Roman Slysh on 10/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <AddressBookUI/AddressBookUI.h>

@interface FreeSMSViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *contacts;
- (IBAction)addNewContact:(id)sender;
- (IBAction)showAddressBook:(id)sender;

@end
