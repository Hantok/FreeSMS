//
//  SQLiteManager.m
//  FreeSMS
//
//  Created by Roman Slysh on 11/26/12.
//  Copyright (c) 2012 Roman Slysh. All rights reserved.
//

#import "SQLiteManager.h"

@implementation SQLiteManager

+ (NSMutableArray *)selectFromTableName:(NSString *)tableName
{
    // Setup the database object
	sqlite3 *database;
	
	// Init the animals Array
	NSMutableArray *result = [[NSMutableArray alloc] init];
	

    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] objectForKey:@"db"]];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = [[NSString stringWithFormat:@"select * from %@" ,tableName] UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                if([tableName isEqualToString:@"Contacts"])
                {
                    // Read the data from the result row
                    NSString *aPhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                    NSString *aName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                    
                    Contact *contact = [[Contact alloc] initWithName:aName phone:aPhone];
                    
                    [result addObject:contact];
                }
                else
                {
                    NSString *aDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                    NSString *aPhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                    NSString *aTxt = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                    
                    Message *message = [[Message alloc] initWithPhone:aPhone date:aDate txt:aTxt];
                    
                    [result addObject:message];
                }
				
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
    
    return result;

}

+ (NSMutableArray *)selectFromMessagesWithPhoneNumber:(NSString *)phone
{
    // Setup the database object
	sqlite3 *database;
	
	// Init the animals Array
	NSMutableArray *result = [[NSMutableArray alloc] init];
	
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] objectForKey:@"db"]];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = [[NSString stringWithFormat:@"select * from Messages WHERE phone = '%@'", phone] UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSString *aDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString *aPhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                NSString *aTxt = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                
                Message *message = [[Message alloc] initWithPhone:aPhone date:aDate txt:aTxt];
                
                [result addObject:message];
				
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
    
    return result;
}

+ (BOOL)insertToContactsWithName:(NSString *)name
                           phone:(NSString *)phone
{
    sqlite3 *database;
    
    //Get list of directories in Document path
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Define new path for database
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:@"SMS.sqlite"];
    
    if(!(sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK))
    {
        NSLog(@"An error has occured.");
        return NO;
    }else
    {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO Contacts (phone,name) VALUES ('%@', '%@');", phone, name] UTF8String];
        
        sqlite3_stmt *sqlStatement;
        if(sqlite3_prepare_v2(database, sql, -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare statement");
            return NO;
        }
        else if(sqlite3_step(sqlStatement)==SQLITE_DONE)
        {
            sqlite3_finalize(sqlStatement);
            sqlite3_close(database);
            return YES;
        }
    }
    return NO;
}

+ (BOOL)insertNewMessageWithText:(NSString *)text
                           phone:(NSString *)phone
                            date:(NSString *)date
{
    sqlite3 *database;
    
    //Get list of directories in Document path
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Define new path for database
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:@"SMS.sqlite"];
    
    if(!(sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK))
    {
        NSLog(@"An error has occured.");
        return NO;
    }else
    {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO Messages (txt,phone,date) VALUES ('%@', '%@', '%@');", text, phone, date] UTF8String];
        
        sqlite3_stmt *sqlStatement;
        if(sqlite3_prepare_v2(database, sql, -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare statement");
            return NO;
        }
        else if(sqlite3_step(sqlStatement)==SQLITE_DONE)
        {
            sqlite3_finalize(sqlStatement);
            sqlite3_close(database);
            return YES;
        }
    }
    return NO;
}

+ (BOOL)deleteContactsWithPhone:(NSString *)phone
{
    sqlite3 *database;
    
    //Get list of directories in Document path
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Define new path for database
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:@"SMS.sqlite"];
    
    if(!(sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK))
    {
        NSLog(@"An error has occured.");
        return NO;
    }else
    {
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM Contacts WHERE phone = '%@'",  phone] UTF8String];
        
        sqlite3_stmt *sqlStatement;
        if(sqlite3_prepare_v2(database, sql, -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare statement");
            return NO;
        }
        else if(sqlite3_step(sqlStatement)==SQLITE_DONE)
        {
            sqlite3_finalize(sqlStatement);
            sqlite3_close(database);
            return YES;
        }
    }
    return NO;
}

+ (BOOL)deleteMessageWithDate:(NSString *)date
{
    sqlite3 *database;
    
    //Get list of directories in Document path
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Define new path for database
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:@"SMS.sqlite"];
    
    if(!(sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK))
    {
        NSLog(@"An error has occured.");
        return NO;
    }else
    {
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM Messages WHERE date = '%@'",  date] UTF8String];
        
        sqlite3_stmt *sqlStatement;
        if(sqlite3_prepare_v2(database, sql, -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare statement");
            return NO;
        }
        else if(sqlite3_step(sqlStatement)==SQLITE_DONE)
        {
            sqlite3_finalize(sqlStatement);
            sqlite3_close(database);
            return YES;
        }
    }
    return NO;
}


@end
