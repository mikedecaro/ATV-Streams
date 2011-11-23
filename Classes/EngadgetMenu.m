//
//  EngadgetCollection.m
//  Engadget
//

#import "EngadgetMenu.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation EngadgetMenu

-(id)previewControlForItem:(long)item
{
    
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
    [a setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[EngadgetMenu class]] pathForResource:@"stream" ofType:@"png"]]];
        
    [a setTitle:[self titleForRow:item]]; 
    SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
    [p setAsset:a];
    [p setShowsMetadataImmediately:YES];
    [a release];
    
    return [p autorelease];
}

- (id)itemForRow:(long)row					{ 
    
    SMFMenuItem *it = [super itemForRow:row];
    if (row<[_options count])
    {
        [it setRightJustifiedText:@"Main Menu" withAttributes:[[BRThemeInfo sharedTheme] menuItemSmallTextAttributes]];
    }
    
    return it;
}

-(id)init
{
    self=[super init];
    if (self) {
        [[self list] setDatasource:self];
        [self setListTitle:@"Engadget"];
        
        dataList = [[NSMutableArray alloc] init];
        
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.viddler.com/api/v2/viddler.videos.getByUser.xml?key=f30360124e9fabd82454e47414447455431e&user=engadget&per_page=12&page=1"]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        // create the connection with the request
        // and start loading the data
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if (theConnection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            receivedData = [[NSMutableData data] retain];
        } else {
            // Inform the user that the connection failed.
        }
        
    }
    return self;
}

- (void)itemSelected:(long)selected
{
    
    if(dataList && selected < [dataList count])
    {
        
        NSArray *itemData = [dataList objectAtIndex:selected];
        NSString *itemSource = [itemData objectAtIndex:1];
        
        NSURL *mediaURL = [NSURL URLWithString:itemSource];
        
        SMFMovieAsset* pma = [[SMFMovieAsset alloc] initWithMediaURL:mediaURL];
        
        BRMediaPlayerManager* mgm = [BRMediaPlayerManager singleton];
        NSError *error = nil;
        BRMediaPlayer *player = [mgm playerForMediaAsset:pma error: &error];
        NSLog(@"pma=%@, mgm=%@, play=%@, err=%@", pma, mgm, player, error);
        if ( error != nil ){
            [pma release];
            return ;
        }
                
        //[mgm presentMediaAsset:pma options:0];
        [mgm presentPlayer:player options:0];
        NSLog(@"presented player");
                       
    }
    
}

- (void)loadMenu
{
    
    if(dataList)
    {
        
        [_items removeAllObjects];
            
        for(NSArray *itemData in dataList) {
            
            NSString *title = [itemData objectAtIndex:0];
            
            SMFMenuItem *result = [SMFMenuItem menuItem];
            [result setTitle:title];
            [_items addObject:result];
            
        }
        
        [self refreshControllerForModelUpdate];
        
    }
        
}

#pragma mark URL Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    [parser release];
            
    [self loadMenu];
    
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

#pragma mark Xml parser

//SHOULD CREATE MEDIA ASSETS AND ADD THEM TO DATA LIST

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *) attributeDict{	
    NSLog(@"found this element: %@", elementName);
    
    if([elementName isEqualToString:@"html5_video_source"]){
        sourceFound = YES;
    } else {
        sourceFound = NO;
    }
    
    if([elementName isEqualToString:@"title"]){
        titleFound = YES;
    } else {
        titleFound = NO;
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if(sourceFound){
        NSArray *data = [[NSArray alloc] initWithObjects:lastTitle, string, nil];
        [dataList addObject:data];
    } else if(titleFound){
        lastTitle = [NSString stringWithString:string];
    }
}

@end
