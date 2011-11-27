//
//  RevisionShowMenu.m
//  Revision3
//

#import "RevisionShowMenu.h"
#import "RevisionEpisodeMenu.h"
#include "JSON/NSDictionary_JSONExtensions.h"
#import <Foundation/Foundation.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation RevisionShowMenu

-(id)previewControlForItem:(long)item
{
    
    NSDictionary *itemData = [dataList objectAtIndex:item];
    NSDictionary *thumbData = [itemData objectForKey:@"images"];
    NSString *thumbSource = [thumbData objectForKey:@"logo"];
    
    NSURL *thumbURL = [NSURL URLWithString:thumbSource];
    BRImage *thumbImg = [BRImage imageWithURL:thumbURL];
    
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
    [a setCoverArt:thumbImg];
    [a setSummary:[itemData objectForKey:@"summary"]];
    
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

-(id)initWithCategory:(NSString *)cat
{
    self=[super init];
    if (self) {
        category = [NSString stringWithString:cat];
        
        [[self list] setDatasource:self];
        [self setListTitle:@"Revision3"];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[RevisionShowMenu class]] pathForResource:@"Revision3_Icon" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
         
//        //Needed? If so, release it before setting a new one after parsing the JSON
//        dataList = [[NSMutableArray alloc] init];
        
        NSString *mediaSource;
        if([category isEqualToString:@"Shows"]) {
            mediaSource = @"http://revision3.com/api/getShows.json?api_key=0b1faede6785d04b78735b139ddf2910f34ad601&grouping=current";
        } else if([category isEqualToString:@"Archived Shows"]) {
            mediaSource = @"http://revision3.com/api/getShows.json?api_key=0b1faede6785d04b78735b139ddf2910f34ad601&grouping=archived";
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
        
        NSDictionary *tempDict = [dataList objectAtIndex:selected];
        NSString *showID = [tempDict objectForKey:@"id"];
        
        RevisionEpisodeMenu *menu = [[RevisionEpisodeMenu alloc] initWithShowId:showID];
        [[self stack]pushController:[menu autorelease]];
        
    }
    
}

- (void)loadMenu
{
    
    if(dataList)
    {
        
        [_items removeAllObjects];
        
        for(NSDictionary *itemData in dataList) {
            
            NSString *title = [itemData objectForKey:@"name"];
            
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
    NSError *theError = NULL;
    NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:string error:&theError];
    
    return [[theDictionary objectForKey:@"shows"] retain];
}

@end
