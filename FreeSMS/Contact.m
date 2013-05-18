//
//  Contacts.m
//  FreeSMS
//
//  Created by Roman Slysh on 11/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@synthesize name, phone;

-(id)initWithName:(NSString *)aName
            phone:(NSString *)aPhone
{
    self.name  = aName;
    self.phone = aPhone;
    return self;
}


@end
