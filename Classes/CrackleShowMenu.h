//
//  CrackleShowMenu.h
//  Crackle
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface CrackleShowMenu : SMFMediaMenuController <NSXMLParserDelegate> {
    NSArray *dataList;
    NSMutableData *receivedData;
    
    int menuType;
    NSString *categoryName;
}

- (id)initWithType:(int)mType category:(NSString *)catName;
- (NSArray*)parseJsonString:(NSString *)string;

@end
