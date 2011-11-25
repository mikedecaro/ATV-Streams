//
//  HowStuffWorksMenu.h
//  HowStuffWorks
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface HowStuffWorksMenu : SMFMediaMenuController <NSXMLParserDelegate> {
    NSMutableArray *dataList;
    NSMutableData *receivedData;
}

- (NSArray*)parseJsonString:(NSString *)string;

@end
