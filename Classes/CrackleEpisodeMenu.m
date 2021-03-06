//
//  CrackleEpisodeMenu.m
//  Crackle
//

#import "CrackleEpisodeMenu.h"
#include "JSON/NSDictionary_JSONExtensions.h"
#import <Foundation/Foundation.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation CrackleEpisodeMenu

-(id)previewControlForItem:(long)item
{
    
    NSDictionary *itemData = [dataList objectAtIndex:item];
    NSString *thumbSource = [itemData objectForKey:@"OneSheetImage185x277"];
    
    NSURL *thumbURL = [NSURL URLWithString:thumbSource];
    BRImage *thumbImg = [BRImage imageWithURL:thumbURL];
    
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
    [a setCoverArt:thumbImg];
    [a setSummary:[itemData objectForKey:@"Description"]];
    
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

- (id)initWithMenuType:(int)mType showId:(NSString *)sId
{
    self=[super init];
    if (self) {
        menuType = mType;
        showId = [NSString stringWithString:sId];
        
        [[self list] setDatasource:self];
        [self setListTitle:@"Crackle"];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[CrackleEpisodeMenu class]] pathForResource:@"Crackle_Icon" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
        
        //        //Needed? If so, release it before setting a new one after parsing the JSON
        //        dataList = [[NSMutableArray alloc] init];
        
        NSString *jsonUrl = [NSString stringWithFormat:@"http://api.crackle.com/Service.svc/channel/%@/folders/US?format=json", showId];
                
        NSLog(@"Show ID: %@", sId);
        
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:jsonUrl]
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
        NSString *mediaId = [tempDict objectForKey:@"ID"];
        
        NSString *jsonUrl = [NSString stringWithFormat:@"http://api.crackle.com/Service.svc/details/media/%@/US?format=json", mediaId];
        
        // Create the request.
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:jsonUrl]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        // create the connection with the request
        // and start loading the data
        NSError *theError;
        NSURLResponse *theResponse;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
        if (returnData) {
            
            NSString* jsonStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
            NSError *theError = NULL;
            NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:jsonStr error:&theError];
            
            NSArray *urlList = [theDictionary objectForKey:@"MediaURLs"];
            NSDictionary *mediaData = [urlList objectAtIndex:2];
            NSString *itemSource = [mediaData objectForKey:@"Path"];
            
            
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
            
        } else {
            // Inform the user that the connection failed.
        }
        
    }
    
}

- (void)loadMenu
{
    
    if(dataList)
    {
        
        [_items removeAllObjects];
        
        for(NSDictionary *itemData in dataList) {
            
            NSString *title = [itemData objectForKey:@"Title"];
            
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
    //TV = check folder list name for Full &&/|| Episodes
    //MOvie = check playlist name for Full Length
    
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    
    NSError *theError = NULL;
    NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:string error:&theError];
    
    if(menuType == 1){
    
        NSArray *folderList = [theDictionary objectForKey:@"FolderList"];
        for(NSDictionary *tempFolder in folderList) {
            NSArray *playlistList = [tempFolder objectForKey:@"PlaylistList"];
            for(NSDictionary *tempPlaylist in playlistList) {
                
                NSString *playlistName = [tempFolder objectForKey:@"Name"];
                if([playlistName isEqualToString:@"Full Length"]){
                    
                    NSArray *mediaList = [tempPlaylist objectForKey:@"MediaList"];
                    [tempList addObjectsFromArray:mediaList];
                    
                }
                
            }
        }
        
    } else if(menuType == 2){
        
        NSArray *folderList = [theDictionary objectForKey:@"FolderList"];
        for(NSDictionary *tempFolder in folderList) {
            
            NSString *folderName = [tempFolder objectForKey:@"Name"];
            NSRange range = [folderName rangeOfString:@"Episodes" options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound) {
            
                NSArray *playlistList = [tempFolder objectForKey:@"PlaylistList"];
                for(NSDictionary *tempPlaylist in playlistList) {
                    NSArray *mediaList = [tempPlaylist objectForKey:@"MediaList"];
                    [tempList addObjectsFromArray:mediaList];
                }
                
            }
            
        }
        
    }
            
    NSArray *array = [NSArray arrayWithArray:tempList];
    [tempList release];
    
    return [array retain];
}

@end
