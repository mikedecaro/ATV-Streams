//
//  CrackleShowMenu.m
//  Crackle
//

#import "CrackleShowMenu.h"
#import "CrackleEpisodeMenu.h"
#include "JSON/NSDictionary_JSONExtensions.h"
#import <Foundation/Foundation.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation CrackleShowMenu

-(id)previewControlForItem:(long)item
{
    
    NSDictionary *itemData = [dataList objectAtIndex:item];
    NSString *thumbSource = [itemData objectForKey:@"ImageUrl10"];
    
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

- (id)initWithType:(int)mType category:(NSString *)catName
{
    self=[super init];
    if (self) {
        categoryName = [NSString stringWithString:catName];
        menuType = mType;
        
        [[self list] setDatasource:self];
        [self setListTitle:categoryName];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[CrackleShowMenu class]] pathForResource:@"Crackle_Icon" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
        
        //        //Needed? If so, release it before setting a new one after parsing the JSON
        //        dataList = [[NSMutableArray alloc] init];
                
        NSString *jsonUrl;
        if(menuType == 1){
            
            if([categoryName isEqualToString:@"Featured"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/featured/movies/all/US/50?format=json";
            } else if([categoryName isEqualToString:@"Most Popular"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/popular/movies/all/US/50?format=json";
            } else if([categoryName isEqualToString:@"Recently Added"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/recent/movies/all/US/50?format=json";
            } else if([categoryName isEqualToString:@"Browse All"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/browse/movies/full/all/alpha/US?format=json";
            }            
            
        } else if (menuType == 2){
            
            if([categoryName isEqualToString:@"Featured"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/featured/television/all/US/50?format=json";
            } else if([categoryName isEqualToString:@"Most Popular"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/popular/television/all/US/50?format=json";
            } else if([categoryName isEqualToString:@"Recently Added"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/recent/television/all/US/50?format=json";
            } else if([categoryName isEqualToString:@"Browse All"]){
                jsonUrl = @"http://api.crackle.com/Service.svc/browse/television/full/all/alpha/US?format=json";
            }
            
        }
                
        NSLog(@"Category: %@", categoryName);
        
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
        
        if(menuType == 1){
            //Movie
                                    
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
            
        } else if(menuType == 2){
            //TV Show
            
            CrackleEpisodeMenu *menu = [[CrackleEpisodeMenu alloc] initWithShowId:mediaId];
            [[self stack]pushController:[menu autorelease]];
            
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
    NSArray *array;
    
    NSError *theError = NULL;
    NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:string error:&theError];
    
    array = [theDictionary objectForKey:@"Items"];
            
    return [array retain];
}

@end
