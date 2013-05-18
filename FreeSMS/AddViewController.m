//
//  AddViewController.m
//  FreeSMS
//
//  Created by Roman Slysh on 1/5/13.
//  Copyright (c) 2013 Roman Slysh. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController ()

@end

@implementation AddViewController

@synthesize nameTextField = _nameTextField;
@synthesize phoneTextField = _phoneTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	// Do any additional setup after loading the view.
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([indexPath row] == 0)
    {
        self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 10, cell.frame.size.width-50, cell.frame.size.height - 10 )];
        self.nameTextField.adjustsFontSizeToFitWidth = YES;
        self.nameTextField.textColor = [UIColor blackColor];
        self.nameTextField.placeholder = @"Name";
        self.nameTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.nameTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.nameTextField.returnKeyType = UIReturnKeyNext;
        self.nameTextField.backgroundColor = [UIColor clearColor];
        self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences; //capitalization support
        self.nameTextField.textAlignment = UITextAlignmentLeft;
        self.nameTextField.tag = 0;
        self.nameTextField.delegate = (id) self;
        [cell addSubview:self.nameTextField];
    }
    else
    {
        self.phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 10, cell.frame.size.width-50, cell.frame.size.height - 10 )];
        self.phoneTextField.adjustsFontSizeToFitWidth = YES;
        self.phoneTextField.textColor = [UIColor blackColor];
        self.phoneTextField.placeholder = @"Phone";
        self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
        self.phoneTextField.returnKeyType = UIReturnKeyDone;
//        self.phoneTextField.secureTextEntry = YES;
        self.phoneTextField.backgroundColor = [UIColor clearColor];
        self.phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        self.phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        self.phoneTextField.textAlignment = UITextAlignmentLeft;
        self.phoneTextField.tag = 0;
        self.phoneTextField.delegate = (id) self;
        
        self.phoneTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        [self.phoneTextField setEnabled: YES];
        
        [cell addSubview:self.phoneTextField];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        [self.nameTextField becomeFirstResponder];
    else
        [self.phoneTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.phoneTextField)
    {
        [textField resignFirstResponder];
        return YES;
    }
    else
    {
        [self.phoneTextField becomeFirstResponder];
        return NO;
    }
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.phoneTextField)
    {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 10 || returnKey;
    }
    else
    {
        return YES;
    }
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
}
- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)add:(id)sender
{
    if (self.nameTextField.text != nil || ![self.nameTextField.text isEqualToString:@""] ||
        self.phoneTextField.text != nil || ![self.phoneTextField.text isEqualToString:@""])
    {
        [SQLiteManager insertToContactsWithName:self.nameTextField.text phone:self.phoneTextField.text];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
