//
//  CrackleMenu.h
//  Crackle
//
//  Created by Mike DeCaro on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <SMFramework/SMFramework.h>

@interface CrackleMenu : SMFMediaMenuController {
    NSArray *dataList;
    int menuType;
}

-(id)initWithType:(int)menuType;

@end
