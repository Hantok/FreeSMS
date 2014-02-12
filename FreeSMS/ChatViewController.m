//
//  ChatViewController.m
//
//  Created by Roman Slysh on 10/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import "ChatViewController.h"
#include "ChatMessageTableViewCell.h"
#import "Reachability.h"
#import "SQLiteManager.h"
#import "Message.h"

@interface ChatViewController ()
{
    BOOL isPicture;
    BOOL isSending;
    BOOL inetConnection;
    BOOL editMode;
    BOOL keyboardShowing;
    int scrolling;
    int scrollingLandscape;
}

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString      *availableSMS;
@property (nonatomic, strong) NSString      *time;
@property (nonatomic, strong) Message       *message;

@end

@implementation ChatViewController

@synthesize sendMessageField;
@synthesize sendMessageButton;
@synthesize tableView;

@synthesize messages = _messages;
@synthesize responseData = _responseData;
@synthesize availableSMS = _availableSMS;
@synthesize contact = _contact;
@synthesize time = _time;
@synthesize message = _message;

- (NSMutableArray *)messages
{
    if (!_messages)
    {
        _messages = [SQLiteManager selectFromMessagesWithPhoneNumber:self.contact.phone];
    }
    return _messages;
}
#pragma mark -
#pragma mark View controller's lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.message = [[Message alloc] init];
    self.navigationItem.title = self.contact.name;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Block Says Reachable");
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Block Says Unreachable");
        });
    };
    
    [reach startNotifier];
    
    [self getScreenConstants];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.messages.count != 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)viewDidUnload
{
    [self setSendMessageField:nil];
    [self setSendMessageButton:nil];
    [self setTableView:nil];
    [self setAntibot:nil];
    [self setAntibotText:nil];
    [self setSmsCountLabel:nil];
    [self setUpdateMe:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Methods


- (IBAction)sendMessage:(id)sender
{
    if(self.sendMessageField.text.length == 0)
    {
        return;
    }
    else if(!inetConnection)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(self.availableSMS.intValue == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"No available SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else if(self.checkForLiteracy)
    {
        isSending = YES;
        [self showLoading];
        
        //make request
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.life.com.ua/sms/smsFree.html"]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:15.0];
        request.HTTPMethod = @"POST";
        
        
        // set POST request parameters
        NSString *code = [self.contact.phone substringToIndex:3];
        NSString *number = [self.contact.phone substringFromIndex:3];
        
        NSString* params = [NSString stringWithFormat:@"smsNumberPrefix=%@&smsNumber=%@&promotionTextObj.id=8&text=%@&signature=Roma&antibot=%@&save=",code, number, self.sendMessageField.text, self.antibotText.text];
        request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection)
        {
            NSLog(@"Connecting...");
        }
        else
        {
            NSLog(@"Connection error!");
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fill all rows please" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    // hide keyboard & clean text field
    [self.sendMessageField resignFirstResponder];
    [self keyboardHide];
}

- (IBAction)updateMe:(id)sender {
    if (inetConnection)
    {
        // make request
        [self showLoading];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.life.com.ua/sms/smsFree.html"]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:30.0];
        request.HTTPMethod = @"GET";
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (connection)
        {
            NSLog(@"Connecting...");
            isPicture = YES;
        }
        else
        {
            NSLog(@"Connection error!");
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)edit:(id)sender {
    editMode = ! editMode;
    if(editMode) {
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        [self.tableView setEditing:NO animated:YES];
    }
}

-(void)keyboardShow{
    keyboardShowing = YES;
    if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [UIView animateWithDuration:0.20F animations:^{
            [self.antibot setFrame:CGRectMake(self.antibot.frame.origin.x
                                              , self.antibot.frame.origin.y - scrollingLandscape
                                              , self.antibot.frame.size.width
                                              , self.antibot.frame.size.height)];
            [self.antibotText setFrame:CGRectMake(self.antibotText.frame.origin.x
                                                  , self.antibotText.frame.origin.y - scrollingLandscape
                                                  , self.antibotText.frame.size.width
                                                  , self.antibotText.frame.size.height)];
            [self.sendMessageField setFrame:CGRectMake(self.sendMessageField.frame.origin.x
                                                       , self.sendMessageField.frame.origin.y - scrollingLandscape
                                                       , self.sendMessageField.frame.size.width
                                                       , self.sendMessageField.frame.size.height)];
            [self.sendMessageButton setFrame:CGRectMake(self.sendMessageButton.frame.origin.x
                                                        , self.sendMessageButton.frame.origin.y - scrollingLandscape
                                                        , self.sendMessageButton.frame.size.width
                                                        , self.sendMessageButton.frame.size.height)];
            [self.updateMe setFrame:CGRectMake(self.updateMe.frame.origin.x
                                                        , self.updateMe.frame.origin.y - scrollingLandscape
                                                        , self.updateMe.frame.size.width
                                                        , self.updateMe.frame.size.height)];
            [self.smsCountLabel setFrame:CGRectMake(self.smsCountLabel.frame.origin.x
                                                    , self.smsCountLabel.frame.origin.y - scrollingLandscape
                                                    , self.smsCountLabel.frame.size.width
                                                    , self.smsCountLabel.frame.size.height)];
                    }];
    } else {
        [UIView animateWithDuration:0.20F animations:^{
            [self.antibot setFrame:CGRectMake(self.antibot.frame.origin.x
                                              , self.antibot.frame.origin.y - scrolling
                                              , self.antibot.frame.size.width
                                              , self.antibot.frame.size.height)];
            [self.antibotText setFrame:CGRectMake(self.antibotText.frame.origin.x
                                                  , self.antibotText.frame.origin.y - scrolling
                                                  , self.antibotText.frame.size.width
                                                  , self.antibotText.frame.size.height)];
            [self.sendMessageField setFrame:CGRectMake(self.sendMessageField.frame.origin.x
                                                       , self.sendMessageField.frame.origin.y - scrolling
                                                       , self.sendMessageField.frame.size.width
                                                       , self.sendMessageField.frame.size.height)];
            [self.sendMessageButton setFrame:CGRectMake(self.sendMessageButton.frame.origin.x
                                                        , self.sendMessageButton.frame.origin.y - scrolling
                                                        , self.sendMessageButton.frame.size.width
                                                        , self.sendMessageButton.frame.size.height)];
            [self.updateMe setFrame:CGRectMake(self.updateMe.frame.origin.x
                                                        , self.updateMe.frame.origin.y - scrolling
                                                        , self.updateMe.frame.size.width
                                                        , self.updateMe.frame.size.height)];
            [self.smsCountLabel setFrame:CGRectMake(self.smsCountLabel.frame.origin.x
                                                    , self.smsCountLabel.frame.origin.y - scrolling
                                                    , self.smsCountLabel.frame.size.width
                                                    , self.smsCountLabel.frame.size.height)];
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x
                                                    , self.tableView.frame.origin.y
                                                    , self.tableView.frame.size.width
                                                    , self.tableView.frame.size.height - scrolling)];
            self.messages.count == 0 ? 0 : [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
            }];
    }
}

-(void)keyboardHide{
    keyboardShowing = NO;
    [UIView animateWithDuration:0.25F animations:^{
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
            [self.antibot setFrame:CGRectMake(self.antibot.frame.origin.x
                                              , self.antibot.frame.origin.y + scrollingLandscape
                                              , self.antibot.frame.size.width
                                              , self.antibot.frame.size.height)];
            [self.antibotText setFrame:CGRectMake(self.antibotText.frame.origin.x
                                                  , self.antibotText.frame.origin.y + scrollingLandscape
                                                  , self.antibotText.frame.size.width
                                                  , self.antibotText.frame.size.height)];
            [self.sendMessageField setFrame:CGRectMake(self.sendMessageField.frame.origin.x
                                                       , self.sendMessageField.frame.origin.y + scrollingLandscape
                                                       , self.sendMessageField.frame.size.width
                                                       , self.sendMessageField.frame.size.height)];
            [self.sendMessageButton setFrame:CGRectMake(self.sendMessageButton.frame.origin.x
                                                        , self.sendMessageButton.frame.origin.y + scrollingLandscape
                                                        , self.sendMessageButton.frame.size.width
                                                        , self.sendMessageButton.frame.size.height)];
            [self.updateMe setFrame:CGRectMake(self.updateMe.frame.origin.x
                                                        , self.updateMe.frame.origin.y + scrollingLandscape
                                                        , self.updateMe.frame.size.width
                                                        , self.updateMe.frame.size.height)];
            [self.smsCountLabel setFrame:CGRectMake(self.smsCountLabel.frame.origin.x
                                                    , self.smsCountLabel.frame.origin.y + scrollingLandscape
                                                    , self.smsCountLabel.frame.size.width
                                                    , self.smsCountLabel.frame.size.height)];
        }
        else{
            [self.antibot setFrame:CGRectMake(self.antibot.frame.origin.x
                                              , self.antibot.frame.origin.y + scrolling
                                              , self.antibot.frame.size.width
                                              , self.antibot.frame.size.height)];
            [self.antibotText setFrame:CGRectMake(self.antibotText.frame.origin.x
                                                  , self.antibotText.frame.origin.y + scrolling
                                                  , self.antibotText.frame.size.width
                                                  , self.antibotText.frame.size.height)];
            [self.sendMessageField setFrame:CGRectMake(self.sendMessageField.frame.origin.x
                                                       , self.sendMessageField.frame.origin.y + scrolling
                                                       , self.sendMessageField.frame.size.width
                                                       , self.sendMessageField.frame.size.height)];
            [self.sendMessageButton setFrame:CGRectMake(self.sendMessageButton.frame.origin.x
                                                        , self.sendMessageButton.frame.origin.y + scrolling
                                                        , self.sendMessageButton.frame.size.width
                                                        , self.sendMessageButton.frame.size.height)];
            [self.smsCountLabel setFrame:CGRectMake(self.smsCountLabel.frame.origin.x
                                                    , self.smsCountLabel.frame.origin.y + scrolling
                                                    , self.smsCountLabel.frame.size.width
                                                    , self.smsCountLabel.frame.size.height)];
            [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x
                                                , self.tableView.frame.origin.y
                                                , self.tableView.frame.size.width
                                                , self.tableView.frame.size.height + scrolling)];
        }
    }];
}


#pragma mark -
#pragma mark TextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(!keyboardShowing)
        [self keyboardShow];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //if empty antibot - get picture
    if(textField == self.antibotText && [self.antibotText.text isEqualToString:@""])
    {
        if (self.smsCountLabel.text.intValue == 0)
            [self updateMe:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self keyboardHide];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark connection with server

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Unable to fetch data");
    [SVProgressHUD showErrorWithStatus:@"Unable to fetch data"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData
                                                   length]);
    if (isPicture)
    {
        //        UIImage *image = [UIImage imageWithData:self.responseData];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://www.life.com.ua/sms/antiBot.html?type=sms"]]];
        [self.antibot setImage:image];
        isPicture = NO;
        [self.antibot setImage:image];
        
//        self.antibotText.text = nil;
//        [self.antibotText becomeFirstResponder];
    }
    
    NSString *txt = [[NSString alloc] initWithData:self.responseData encoding: NSUTF8StringEncoding];
    
    NSRange beginning = [txt rangeOfString:@"freeSmsRemain"];
    if (beginning.length != 0)
    {
        //how mane can we send for now?
        NSString *sub1 = [[txt substringFromIndex:NSMaxRange(beginning) + 2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        txt = [[sub1 substringToIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //        NSLog(@"strinng is - %@",txt);
        self.smsCountLabel.text = txt;
        
        if (isSending == YES)
        {
            if ([self.availableSMS isEqualToString:txt])
            {
                self.availableSMS = txt;
                [SVProgressHUD showErrorWithStatus:@"Not sent!"];
            }
            else
            {
                self.availableSMS = txt;
                [SVProgressHUD showSuccessWithStatus:@"Sent! :)"];
                isSending = NO;
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat: @"yyyy-mm-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
                self.time = [formatter stringFromDate:[NSDate date]];
                
                
                self.message.txt = self.sendMessageField.text;
                self.message.phone = self.contact.phone;
                self.message.date = self.time;
                
                self.messages = nil;
                
                [SQLiteManager insertNewMessageWithText:self.sendMessageField.text phone:self.contact.phone date:self.time];
                
                [self.sendMessageField setText:nil];
                
                [self.tableView reloadData];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
        }
        else
        {
            self.availableSMS = txt;
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
    }
}

#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

static CGFloat padding = 20.0;

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    
    // Create cell
	ChatMessageTableViewCell *cell = (ChatMessageTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:CellIdentifier];
	}
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = YES;
    
    // set message's text
	cell.message.text = [[self.messages objectAtIndex:indexPath.row] txt];
	
	CGSize textSize = { 260.0, 10000.0 };
	CGSize size = [cell.message.text sizeWithFont:[UIFont boldSystemFontOfSize:13]
					  constrainedToSize:textSize
						  lineBreakMode:NSLineBreakByWordWrapping];
	size.width += (padding/2);
	
    
    // Left/Right bubble
    UIImage *bgImage = nil;
        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.message setFrame:CGRectMake(320 - size.width - padding,
                                          padding*2,
                                          size.width+padding,
                                          size.height+padding)];
        
        [cell.backgroundImageView setFrame:CGRectMake(cell.message.frame.origin.x - padding/2,
                                                      cell.message.frame.origin.y - padding/2,
                                                      size.width+padding,
                                                      size.height+padding)];
        
        cell.date.textAlignment = NSTextAlignmentRight;
        cell.backgroundImageView.image = bgImage;
        cell.date.text = [NSString stringWithFormat:@"%@", [[self.messages objectAtIndex:indexPath.row] date]];
    
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *msg = [[self.messages objectAtIndex:indexPath.row] txt];
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13]
                  constrainedToSize:textSize 
                      lineBreakMode:NSLineBreakByCharWrapping];
	
	size.height += padding;
	return size.height+padding+10;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [SQLiteManager deleteMessageWithDate:[(Message *)[self.messages objectAtIndex:indexPath.row] date]];
        [self.messages removeObjectAtIndex:indexPath.row];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark Private methods

- (BOOL)checkForLiteracy
{
    if([self.antibotText.text isEqualToString:@""]/* || [self.codeForNumberLabel.text isEqualToString:@""] || [self.phoneNumber.text isEqualToString:@""]*/)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)showLoading
{
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeBlack];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        NSLog(@"Notification Says Reachable");
        inetConnection = YES;
    }
    else
    {
        NSLog(@"Notification Says Unreachable");
        inetConnection = NO;
    }
}

- (void) getScreenConstants {
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    scrolling = 215;
    scrollingLandscape = 170;
}

@end
