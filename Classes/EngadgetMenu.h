//
//  EngadgetMenu.h
//  Engadget
//
#import <SMFramework/SMFramework.h>

@interface EngadgetMenu : SMFMediaMenuController {
    NSArray *dataList;
}

- (void)loadMenu;

@end
