//
//  CbsNewsMenu.h
//  CBS News
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface CbsNewsMenu : SMFMediaMenuController {
    NSArray *dataList;
    NSMutableData *receivedData;
}

@end
