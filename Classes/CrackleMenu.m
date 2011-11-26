//
//  CrackleMenu.m
//  Crackle
//

#import "CrackleMenu.h"
#import "CrackleShowMenu.h"
#import <Foundation/Foundation.h>
#import <SMFramework/SMFMovieAsset.h>

@implementation CrackleMenu

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
    return [self initWithType:0];
}

-(id)initWithType:(int)mType
{
    self=[super init];
    if (self) {
        [[self list] setDatasource:self];
        [self setListTitle:@"Crackle"];
        [self setListIcon:[BRImage imageWithPath:[[NSBundle bundleForClass:[CrackleMenu class]] pathForResource:@"Crackle" ofType:@"png"]] horizontalOffset:0.0f kerningFactor:0.0f];
        
        menuType = mType;
        
        if(menuType == 0){
            dataList = [[NSMutableArray alloc] initWithObjects:@"Movies", @"Shows", nil];
        } else {
//            dataList = [[NSMutableArray alloc] initWithObjects:@"Featured", @"Most Popular", @"Recently Added", @"Browse All", nil];
            dataList = [[NSMutableArray alloc] initWithObjects:@"Featured", @"Most Popular", @"Recently Added", nil];
        }
        
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
        
        NSString *selectedTitle = [dataList objectAtIndex:selected];
        if(menuType == 0 && [selectedTitle isEqualToString:@"Movies"]) {
            
            CrackleMenu *menu = [[CrackleMenu alloc] initWithType:1];
            [[self stack]pushController:[menu autorelease]];
            
        } else if([selectedTitle isEqualToString:@"Shows"]) {
            
            CrackleMenu *menu = [[CrackleMenu alloc] initWithType:2];
            [[self stack]pushController:[menu autorelease]];
            
        } else {
            
            CrackleShowMenu *menu = [[CrackleShowMenu alloc] initWithType:menuType category:[dataList objectAtIndex:selected]];
            [[self stack]pushController:[menu autorelease]];
            
        }
        
    }
    
}

@end
