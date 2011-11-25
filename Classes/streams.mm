//
//  streams.mm
//  Streams
//

//#import "rdio.h"
#import <Foundation/Foundation.h>
#import "CPlusFunctions.mm"
#import "EngadgetMenu.h"
#import "RevisionMenu.h"

#define kSMFApplianceOrderKey   @"FRAppliancePreferedOrderValue"

#define ENGADGET_ID @"engadgetId"
#define REVISION_ID @"revisionId"

#define ENGADGET_CAT [BRApplianceCategory categoryWithName:@"Engadget" identifier:ENGADGET_ID preferredOrder:1]
#define REVISION_CAT [BRApplianceCategory categoryWithName:@"Revision3" identifier:REVISION_ID preferredOrder:2]

@interface BRTopShelfView (specialAdditions)

- (BRImageControl *)productImage;

@end

@implementation BRTopShelfView (specialAdditions)

- (BRImageControl *)productImage
{
	return MSHookIvar<BRImageControl *>(self, "_productImage");
}

@end

///////////

@interface OFTopShelfController : NSObject {
}
- (void)selectCategoryWithIdentifier:(id)identifier;
- (id)topShelfView;
@end

@implementation OFTopShelfController

- (void)selectCategoryWithIdentifier:(id)identifier {
	
}

-(void)refresh {
}

- (BRTopShelfView *)topShelfView {
	
	BRTopShelfView *topShelf = [[BRTopShelfView alloc] init];
	BRImageControl *imageControl = [topShelf productImage];
	BRImage *gpImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[EngadgetMenu class]] pathForResource:@"stream" ofType:@"png"]];
	[imageControl setImage:gpImage];
	
	return topShelf;
}
@end

///////////

@interface streamsAppliance : BRBaseAppliance {
    NSArray *_applianceCategories;
    OFTopShelfController *_topShelfController;
}
@property(nonatomic, readonly, retain) id topShelfController;

-(void) loadMenu;

@end

@implementation streamsAppliance

@synthesize topShelfController=_topShelfController;

-(id)init
{
    if((self = [super init]) != nil) 
    {
        
        _topShelfController=[[OFTopShelfController alloc] init];
        
        [self loadMenu];
                
	}
    return self;
}

-(void) loadMenu
{
    
    _applianceCategories = [[NSArray alloc] initWithObjects:ENGADGET_CAT, REVISION_CAT, nil];        
    
}

#pragma mark -

- (id)applianceCategories {
	return _applianceCategories;
}

- (id)identifierForContentAlias:(id)contentAlias {
	return @"Streams";
}

- (BOOL)handleObjectSelection:(id)fp8 userInfo:(id)fp12 {
	return YES;
}

- (id)applianceSpecificControllerForIdentifier:(id)arg1 args:(id)arg2 {
    return nil;
}
- (BOOL)handlePlay:(id)play userInfo:(id)info
{
    return YES;
}

- (id)controllerForIdentifier:(id)identifier args:(id)args
{
	
	id menuController = nil;
	
	if([identifier isEqualToString:ENGADGET_ID]) {
        menuController = [[[EngadgetMenu alloc] init] autorelease];
    } else if([identifier isEqualToString:REVISION_ID]) {
        menuController = [[[RevisionMenu alloc] init] autorelease];
    }
    
    return menuController;
    
}

- (id)localizedSearchTitle { return @"Streams"; }
- (id)applianceName { return @"Streams"; }
- (id)moduleName { return @"Streams"; }
- (id)applianceKey { return @"Streams"; }

@end
