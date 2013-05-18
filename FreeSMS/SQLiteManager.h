//
//  SQLiteManager.h
//  FreeSMS
//
//  Created by Roman Slysh on 11/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Contact.h"
#import "Message.h"

@interface SQLiteManager : NSObject

+ (NSMutableArray *)selectFromTableName:(NSString *)tableName;
+ (BOOL)insertToContactsWithName:(NSString *)name
                       phone:(NSString *)phone;
+ (BOOL)insertNewMessageWithText:(NSString *)text
                           phone:(NSString *)phone
                            date:(NSString *)date;
+ (NSMutableArray *)selectFromMessagesWithPhoneNumber:(NSString *)phone;

+ (BOOL)deleteContactsWithPhone:(NSString *)phone;

+ (BOOL)deleteMessageWithDate:(NSString *)date;
@end
