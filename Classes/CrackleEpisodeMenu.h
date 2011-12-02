//
//  CrackleEpisodeMenu.h
//  Crackle
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface CrackleEpisodeMenu : SMFMediaMenuController {
    NSArray *dataList;
    NSMutableData *receivedData;
    
    NSString *showId;
    int menuType;
}

- (id)initWithMenuType:(int)mType showId:(NSString *)sId;
- (NSArray*)parseJsonString:(NSString *)string;

@end
