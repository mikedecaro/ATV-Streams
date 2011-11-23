//
//  RdioCollection.h
//  Rdio
//
#import <SMFramework/SMFramework.h>

@interface EngadgetMenu : SMFMediaMenuController <NSXMLParserDelegate> {
    NSMutableArray *dataList;
    NSMutableData *receivedData;
    bool sourceFound;
    bool titleFound;
    NSString *lastTitle;
}

@end
