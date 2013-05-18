//
//  Message.m
//  FreeSMS
//
//  Created by Roman Slysh on 11/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize date, phone, txt;

-(id)initWithPhone:(NSString *)aPhone
              date:(NSString *)aDate
               txt:(NSString *)aTxt
{
    self.phone = aPhone;
    self.date  = aDate;
    self.txt   = aTxt;
    return self;
}

@end
