//
//  EngadgetMenu.h
//  Engadget
//
#import <SMFramework/SMFramework.h>

@interface EngadgetMenu : SMFMediaMenuController <NSXMLParserDelegate> {
    NSMutableArray *dataList;
    NSMutableData *receivedData;
    NSMutableDictionary *currentVideo;
    NSString *currentTag;
}

@end
