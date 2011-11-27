//
//  EngadgetShowMenu.h
//  Engadget
//
#import <SMFramework/SMFramework.h>

@interface EngadgetShowMenu : SMFMediaMenuController <NSXMLParserDelegate> {
    NSMutableArray *dataList;
    NSMutableData *receivedData;
    NSMutableDictionary *currentVideo;
    NSString *currentTag;
    
    NSString *category;
}

- (id)initWithCategory:(NSString *)cat;

@end
