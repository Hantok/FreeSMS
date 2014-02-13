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
    NSInteger selectedIndex;
    NSInteger countOfContacts;
}

@end

@implementation FreeSMSViewController

@synthesize contacts = _contacts;

#pragma mark LifeCircle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Query the database for all contacts records and construct the "contacts" array
    self.contacts = [SQLiteManager selectFromTableName:@"Contacts"];
    
    // Create the refresh, fixed-space (optional), and profile buttons.
    UIBarButtonItem *addressBookItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showAddressBook)];
    
    //    // Optional: if you want to add space between the refresh & profile buttons
    //    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //    fixedSpaceBarButtonItem.width = 12;
    
    UIBarButtonItem *profileBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(about)];
    profileBarButtonItem.style = UIBarButtonItemStyleBordered;
    
    self.navigationItem.rightBarButtonItems = @[addressBookItem, /* fixedSpaceBarButtonItem, */ profileBarButtonItem];
    
    [super viewDidLoad];
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

- (void)showAddressBook {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
}

- (void)about {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"FreeSMS" message:@"Copyright (c) 2012 Roman Slysh. All rights reserved.\n https://github.com/Hantok/FreeSMS" delegate:nil cancelButtonTitle:@"OK :)" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)displayPerson:(ABRecordRef)person
{
    NSString* name = @"";
    NSString* phone = @"[None]";
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (firstName.length != 0) {
        if (lastName.length != 0) {
            name =[NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }else {
            name = firstName;
        }
    }
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++){
            NSString* fetchedPhone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            fetchedPhone = [[fetchedPhone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            NSRange zero = [fetchedPhone rangeOfString:@"0"];
            fetchedPhone = [fetchedPhone substringFromIndex:(NSMaxRange(zero) - 1)];
            NSString* code = [fetchedPhone substringToIndex:3];
            if ( [code isEqualToString:@"063"] || [code isEqualToString:@"093"]) {
                phone = fetchedPhone;
                break;
            }
        }
    }
    [SQLiteManager insertToContactsWithName:name phone:phone];
    self.contacts = [SQLiteManager selectFromTableName:@"Contacts"];
    [self.tableView reloadData];
}

@end
