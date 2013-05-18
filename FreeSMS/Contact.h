//
//  Contacts.h
//  FreeSMS
//
//  Created by Roman Slysh on 11/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *name;

-(id)initWithName:(NSString *)aName
            phone:(NSString *)aPhone;

@end
