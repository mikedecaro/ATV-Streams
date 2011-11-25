//
//  CbsNewsMenu.m
//  CBS News
//

#import "CbsNewsMenu.h"
#import "CbsNewsShowMenu.h"
#import <Foundation/Foundation.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation CbsNewsMenu

-(id)previewControlForItem:(long)item
{
    
//    NSDictionary *itemData = [dataList objectAtIndex:item];
//    NSDictionary *thumbData = [itemData objectForKey:@"images"];
//    NSString *thumbSource = [thumbData objectForKey:@"large"];
    
//    NSURL *thumbURL = [NSURL URLWithString:thumbSource];
//    BRImage *thumbImg = [BRImage imageWithURL:thumbURL];
    
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
//    [a setCoverArt:thumbImg];
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
        [self setListTitle:@"CBS News"];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[CbsNewsMenu class]] pathForResource:@"CBSNews" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
        
        dataList = [[NSMutableArray alloc] initWithObjects:@"CBS Evening News", @"The Early Show", @"48 Hours Mystery", @"Sunday Morning", @"Face the Nation", @"Up to the Minute", nil];
        
        for(NSString *title in dataList) {
            
            SMFMenuItem *result = [SMFMenuItem menuItem];
            [result setTitle:title];
            [_items addObject:result];
            
        }
    }
    return self;
}

- (void)itemSelected:(long)selected
{
    
    if(dataList && selected < [dataList count])
    {
        
        CbsNewsShowMenu *menu = [[CbsNewsShowMenu alloc] initWithShow:[dataList objectAtIndex:selected]];
        [[self stack]pushController:[menu autorelease]];
        
    }
    
}

@end
