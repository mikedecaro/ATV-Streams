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
}

- (id)initWithShowId:(NSString *)sId;
- (NSArray*)parseJsonString:(NSString *)string;

@end
