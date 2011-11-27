//
//  RevisionShowMenu.h
//  Revision3
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface RevisionShowMenu : SMFMediaMenuController {
    NSArray *dataList;
    NSMutableData *receivedData;
    
    NSString *category;
}

- (NSArray*)parseJsonString:(NSString *)string;
-(id)initWithCategory:(NSString *)cat;

@end
