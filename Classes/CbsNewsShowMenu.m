//
//  CbsNewsShowMenu.m
//  CBS News
//

#import "CbsNewsShowMenu.h"
#include "JSON/NSDictionary_JSONExtensions.h"
#import <Foundation/Foundation.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation CbsNewsShowMenu

-(id)previewControlForItem:(long)item
{
    
    NSDictionary *itemData = [dataList objectAtIndex:item];
    NSString *thumbSource = [itemData objectForKey:@"thumbnailMedium"];
    
    NSURL *thumbURL = [NSURL URLWithString:thumbSource];
    BRImage *thumbImg = [BRImage imageWithURL:thumbURL];
    
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
    [a setCoverArt:thumbImg];
    [a setSummary:[itemData objectForKey:@"description"]];
    
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

-(id)initWithShow:(NSString *)showName
{
    self=[super init];
    if (self) {
        [[self list] setDatasource:self];
        [self setListTitle:showName];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[CbsNewsShowMenu class]] pathForResource:@"CBSNews_Icon" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
        
//        //Needed? If so, release it before setting a new one after parsing the JSON
//        dataList = [[NSMutableArray alloc] init];
        
        NSString *showUrl;
        if([showName isEqualToString:@"CBS Evening News"]){
            showUrl = @"http://cbsnews.treemo.com/cbsnews/cnetcombinedlist?app_name=cbsnews&page=1&videoCategory=18563,503445&newsCategory=18563&limit=30&version=1%2E3%2E2&device=ipad";
        } else if([showName isEqualToString:@"The Early Show"]){
            showUrl = @"http://cbsnews.treemo.com/cbsnews/cnetcombinedlist?app_name=cbsnews&page=1&videoCategory=500202&newsCategory=500202&limit=30&version=1%2E3%2E2&device=ipad";
        } else if([showName isEqualToString:@"48 Hours Mystery"]){
            showUrl = @"http://cbsnews.treemo.com/cbsnews/cnetcombinedlist?app_name=cbsnews&page=1&videoCategory=18559,503443&newsCategory=18559&limit=30&version=1%2E3%2E2&device=ipad";
        } else if([showName isEqualToString:@"Sunday Morning"]){
            showUrl = @"http://cbsnews.treemo.com/cbsnews/cnetcombinedlist?app_name=cbsnews&page=1&videoCategory=3445&newsCategory=3445&limit=30&version=1%2E3%2E2&device=ipad";
        } else if([showName isEqualToString:@"Face the Nation"]){
            showUrl = @"http://cbsnews.treemo.com/cbsnews/cnetcombinedlist?app_name=cbsnews&page=1&videoCategory=3460&newsCategory=3460&limit=30&version=1%2E3%2E2&device=ipad";
        } else if([showName isEqualToString:@"Up to the Minute"]){
            showUrl = @"http://cbsnews.treemo.com/cbsnews/cnetcombinedlist?app_name=cbsnews&page=1&videoCategory=3455&newsCategory=3455&limit=30&version=1%2E3%2E2&device=ipad";
        }
        
        NSLog(@"Show: %@", showName);
                
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:showUrl]
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
        NSString *itemSource = [itemData objectForKey:@"playUrl"];
        
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
    NSString* jsonStr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    //Parse the JSON
    dataList = [self parseJsonString:jsonStr];
    
    [jsonStr release];
    
    
    [self loadMenu];
    
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

- (NSArray*)parseJsonString:(NSString *)string
{
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    
    NSError *theError = NULL;
    NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:string error:&theError];
    
    NSDictionary *temp1 = [theDictionary objectForKey:@"videos"];
    for(id key in temp1) {
        NSDictionary *tempDict = [temp1 objectForKey:key];
        [tempList addObjectsFromArray:[tempDict objectForKey:@"list"]];
    }
    
    NSArray *array = [NSArray arrayWithArray:tempList];
    [tempList release];
    
    return [array retain];
}

@end
