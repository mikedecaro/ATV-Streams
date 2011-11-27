//
//  RevisionMenu.m
//  Revision3
//

#import "RevisionMenu.h"
#import "RevisionShowMenu.h"
#import "RevisionEpisodeMenu.h"
#include "JSON/NSDictionary_JSONExtensions.h"
#import <Foundation/Foundation.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation RevisionMenu

-(id)previewControlForItem:(long)item
{
    
    BRImage *thumbImg = [BRImage imageWithPath:[[NSBundle bundleForClass:[RevisionMenu class]] pathForResource:@"Revision3" ofType:@"png"]];
    
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
    [a setCoverArt:thumbImg];
//    [a setSummary:[itemData objectForKey:@"summary"]];
    
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
        [self setListTitle:@"Revision3"];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[RevisionMenu class]] pathForResource:@"Revision3_Icon" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
         
        dataList = [[NSArray alloc] initWithObjects:@"Shows", @"Latest Episodes", @"Archived Shows", nil];
        
        [self loadMenu];
    }
    return self;
}

- (void)itemSelected:(long)selected
{
    
    if(dataList && selected < [dataList count])
    {
        
        NSString *title = [dataList objectAtIndex:selected];
        if([title isEqualToString:@"Latest Episodes"]){
            RevisionEpisodeMenu *menu = [[RevisionEpisodeMenu alloc] initWithShowId:@"-1"];
            [[self stack]pushController:[menu autorelease]];
        } else {
            RevisionShowMenu *menu = [[RevisionShowMenu alloc] initWithCategory:title];
            [[self stack]pushController:[menu autorelease]];
        }
        
    }
    
}

- (void)loadMenu
{
    
    if(dataList)
    {
        
        [_items removeAllObjects];
        
        for(NSString *title in dataList) {
            
            SMFMenuItem *result = [SMFMenuItem menuItem];
            [result setTitle:title];
            [_items addObject:result];
            
        }
        
        [self refreshControllerForModelUpdate];
        
    }
    
}

@end
