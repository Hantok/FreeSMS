//
//  FreeSMSViewController.m
//  FreeSMS
//
//  Created by Roman Slysh on 10/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import "FreeSMSViewController.h"
#import "Contact.h"
#import "SQLiteManager.h"
#import "ChatViewController.h"

@interface FreeSMSViewController ()
{
    int selectedIndex;
    int countOfContacts;
}

//@property (nonatomic, strong) NSString *databasePath;
//@property (nonatomic, strong) NSString *databaseName;

@end

@implementation FreeSMSViewController

@synthesize contacts = _contacts;
//@synthesize databasePath = _databasePath;
//@synthesize databaseName = _databaseName;

#pragma mark LifeCircle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Query the database for all contacts records and construct the "contacts" array
    self.contacts = [SQLiteManager selectFromTableName:@"Contacts"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray *array = [SQLiteManager selectFromTableName:@"Contacts"];
    if (array.count != countOfContacts)
    {
        self.contacts = array.mutableCopy;
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    countOfContacts = self.contacts.count;
    return countOfContacts;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[self.contacts objectAtIndex:indexPath.row] name];
    cell.detailTextLabel.text = [[self.contacts objectAtIndex:indexPath.row] phone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"toSMSView" sender:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [SQLiteManager deleteContactsWithPhone:[[self.contacts objectAtIndex:indexPath.row] phone]];
        [self.contacts removeObjectAtIndex:indexPath.row];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

#pragma mark IBActions

- (IBAction)addNewContact:(id)sender {
    [SQLiteManager insertToContactsWithName:@"Єгор" phone:@"0935067783"];
    self.contacts = [SQLiteManager selectFromTableName:@"Contacts"];
    [self.tableView reloadData];
}

- (IBAction)showAddressBook:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
}

#pragma mark
#pragma mark Address book

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self displayPerson:person];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

#pragma mark Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toSMSView"])
        [segue.destinationViewController setContact:[self.contacts objectAtIndex:selectedIndex]];
}

#pragma mark Private methods

- (void)displayPerson:(ABRecordRef)person
{
    NSString* name =[NSString stringWithFormat:@"%@ %@",(__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty), (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty)];
                                                                                                                                                                                           
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    NSRange zero = [phone rangeOfString:@"0"];
    if(zero.length != 0 && zero.location < 6)
    {
//        NSString *code;
        phone = [phone substringFromIndex:(NSMaxRange(zero) - 1)];
        if (zero.location == 0)
        {
//            code = [phone substringToIndex:(NSMaxRange(zero) + 2)];
            phone = [phone substringFromIndex:(NSMaxRange(zero) + 2)];
        }
    }
//        else
//        {
//            code = [phone substringToIndex:(NSMaxRange(zero) - 1)];
//            phone = [phone substringFromIndex:(NSMaxRange(zero) - 1)];
//        }
    
        [SQLiteManager insertToContactsWithName:name phone:phone];
        self.contacts = [SQLiteManager selectFromTableName:@"Contacts"];
        [self.tableView reloadData];
        
//        self.codeForNumberLabel.text = code;
//        self.phoneNumber.text = phone;
//    }
//    else
//    {
//        NSLog(@"Impossible");
//    }
}



@end
