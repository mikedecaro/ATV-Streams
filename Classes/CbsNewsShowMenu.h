//
//  CbsNewsShowMenu.h
//  CBS News
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface CbsNewsShowMenu : SMFMediaMenuController <NSXMLParserDelegate> {
    NSArray *dataList;
    NSMutableData *receivedData;
}

- (id)initWithShow:(NSString *)showName;
- (NSArray*)parseJsonString:(NSString *)string;

@end
