//
//  EngadgetShowMenu.m
//  Engadget
//

#import "EngadgetShowMenu.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation EngadgetShowMenu

-(id)previewControlForItem:(long)item
{
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
    
    NSDictionary *itemData = [dataList objectAtIndex:item];
    [a setSummary:[itemData objectForKey:@"description"]];
    
    if(![category isEqualToString:@"The Engadget Show"]) {
    
        
        NSString *thumbSource = [itemData objectForKey:@"thumbnail_url"];
        
        NSURL *thumbURL = [NSURL URLWithString:thumbSource];
        BRImage *thumbImg = [BRImage imageWithURL:thumbURL];
            
        [a setCoverArt:thumbImg];
        
    }
        
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

- (id)initWithCategory:(NSString *)cat
{
    self=[super init];
    if (self) {
        category = [NSString stringWithString:cat];
        NSLog(@"Category: %@", category);
        
        [[self list] setDatasource:self];
        [self setListTitle:@"Engadget"];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[EngadgetShowMenu class]] pathForResource:@"Engadget_Icon" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
        
        dataList = [[NSMutableArray alloc] init];
        
        NSString *mediaSource;
        if([category isEqualToString:@"All Videos"]){
            mediaSource = @"http://api.viddler.com/api/v2/viddler.videos.getByUser.xml?key=f30360124e9fabd82454e47414447455431e&user=engadget&per_page=12&page=1";
        } else if([category isEqualToString:@"Featured"]){
            mediaSource = @"http://api.viddler.com/api/v2/viddler.videos.getByUser.xml?key=f30360124e9fabd82454e47414447455431e&user=engadget&per_page=12&page=1&tags=featured";
        } else if([category isEqualToString:@"The Engadget Show"]){
            mediaSource = @"http://feeds.castfire.com/rss/1:12/aol/engadget/show/video:adaptive.m3u8/";
        }
        
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:mediaSource]
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
        
        NSDictionary *itemData = [dataList objectAtIndex:selected];
        
        NSString *itemSource;
        if([category isEqualToString:@"The Engadget Show"]){
            itemSource = [itemData objectForKey:@"guid"];
        } else {
            itemSource = [itemData objectForKey:@"html5_video_source"];
        }
        
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
            
        for(NSDictionary *itemData in dataList) {
            
            NSString *title = [itemData objectForKey:@"title"];
            
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
    
    if(currentVideo != nil){
        [currentVideo release];
        currentVideo = nil;
    }
    
    [self loadMenu];
    
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

#pragma mark Xml parser

//SHOULD CREATE MEDIA ASSETS AND ADD THEM TO DATA LIST

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *) attributeDict{	
    NSLog(@"Start element: %@", elementName);
    
    currentTag = [NSString stringWithString:elementName];
    
    BOOL useItemTag = [category isEqualToString:@"The Engadget Show"];
    
    if((useItemTag && [elementName isEqualToString:@"item"]) || (!useItemTag && [elementName isEqualToString:@"video"])){
        if(currentVideo != nil){
            [currentVideo release];
        }
        
        currentVideo = [[NSMutableDictionary alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
    NSLog(@"End element: %@", elementName);
    
    BOOL useItemTag = [category isEqualToString:@"The Engadget Show"];
    
    if(currentVideo != nil && ((useItemTag && [elementName isEqualToString:@"item"]) || (!useItemTag && [elementName isEqualToString:@"video"]))){
        [dataList addObject:currentVideo];
        [currentVideo release];
        currentVideo = nil;
    }
    
    currentTag = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"String data: %@", string);
    
    if(currentVideo != nil && currentTag != nil){
        [currentVideo setObject:string forKey:currentTag];
    }
}

@end
