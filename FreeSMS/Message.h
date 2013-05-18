//
//  Message.h
//  FreeSMS
//
//  Created by Roman Slysh on 11/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *txt;

-(id)initWithPhone:(NSString *)aPhone
              date:(NSString *)aDate
               txt:(NSString *)aTxt;

@end
