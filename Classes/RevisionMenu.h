//
//  RevisionMenu.h
//  Revision3
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface RevisionMenu : SMFMediaMenuController {
    NSArray *dataList;
}

- (void)loadMenu;

@end
