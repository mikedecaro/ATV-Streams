//
//  EngadgetMenu.m
//  Engadget
//

#import "EngadgetMenu.h"
#import "EngadgetShowMenu.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation EngadgetMenu

-(id)previewControlForItem:(long)item
{
     
    SMFBaseAsset *a = [[SMFBaseAsset alloc] init];
    [a setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[EngadgetMenu class]] pathForResource:@"Engadget" ofType:@"png"]]];
    
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
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[EngadgetMenu class]] pathForResource:@"Engadget_Icon" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
        
        dataList = [[NSArray alloc] initWithObjects:@"All Videos", @"Featured", @"The Engadget Show", nil];
        
        [self loadMenu];
    }
    return self;
}

- (void)itemSelected:(long)selected
{
    
    if(dataList && selected < [dataList count])
    {
        
        NSString *title = [dataList objectAtIndex:selected];
        EngadgetShowMenu *menu = [[EngadgetShowMenu alloc] initWithCategory:title];
        [[self stack]pushController:[menu autorelease]];
                       
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
