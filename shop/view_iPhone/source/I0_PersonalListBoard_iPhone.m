//
//                       __
//                      /\ \   _
//    ____    ____   ___\ \ \_/ \           _____    ___     ___
//   / _  \  / __ \ / __ \ \    <     __   /\__  \  / __ \  / __ \
//  /\ \_\ \/\  __//\  __/\ \ \\ \   /\_\  \/_/  / /\ \_\ \/\ \_\ \
//  \ \____ \ \____\ \____\\ \_\\_\  \/_/   /\____\\ \____/\ \____/
//   \/____\ \/____/\/____/ \/_//_/         \/____/ \/___/  \/___/
//     /\____/
//     \/___/
//
//  Powered by BeeFramework
//

#import "I0_PersonalListBoard_iPhone.h"
#import "AppBoard_iPhone.h"
#import "BaseBoard_iPhone.h"

#import "controller.h"
#import "model.h"

#import "I0_TestListCell_iPhone.h"



#pragma mark -

@implementation I0_PersonalListBoard_iPhone

SUPPORT_RESOURCE_LOADING( YES )
SUPPORT_AUTOMATIC_LAYOUT( YES )

DEF_OUTLET( BeeUIScrollView, list )

DEF_MODEL( SearchCategoryModel, searchCategoryModel )

- (void)load
{
    self.searchCategoryModel = [SearchCategoryModel modelWithObserver:self];
}

- (void)unload
{
    SAFE_RELEASE_MODEL( self.searchCategoryModel );
}

#pragma mark -

ON_CREATE_VIEWS( signal )
{
    [self showNavigationBarAnimated:NO];
    
    @weakify(self);
    
    self.navigationBarTitle=__TEXT(@"ecmobile");
    
    
    $(@"#title").TEXT(__TEXT(@"purchased_list"));
    $(@"#title2").TEXT(__TEXT(@"personal_recommend"));
    self.list.lineCount = 4;
    self.list.animationDuration = 0.25f;
    self.list.width=self.list.width*0.9;
    
    self.list.whenReloading = ^
    {
        @normalize(self);
        
        self.list.total = self.searchCategoryModel.categories.count*4;
        
        for ( int i = 0; i < self.searchCategoryModel.categories.count*4; i++ )
        {
            BeeUIScrollItem * item = self.list.items[i];
            item.clazz = [I0_TestListCell_iPhone  class];
            item.size = CGSizeMake( self.list.width/self.list.lineCount, (self.list.width/self.list.lineCount)*1.2 );
            item.data = [self.searchCategoryModel.categories safeObjectAtIndex:i];
            item.rule = BeeUIScrollLayoutRule_Tile;
        }
    };
}

ON_DELETE_VIEWS( signal )
{
    
    self.list = nil;
}

ON_LAYOUT_VIEWS( signal )
{
}

ON_WILL_APPEAR( signal )
{
    [bee.ui.appBoard showTabbar];
    
    [self.searchCategoryModel reload];
    [[CartModel sharedInstance] reload];
    
    [self.list reloadData];
}

ON_DID_APPEAR( signal )
{
}

ON_WILL_DISAPPEAR( signal )
{
    
    [self dismissModalViewAnimated:YES];
    
    [bee.ui.appBoard hideTabbar];
    
    [CartModel sharedInstance].loaded = NO;
}

ON_DID_DISAPPEAR( signal )
{
}



#pragma mark -

ON_MESSAGE3( API, category, msg )
{
    if ( msg.sending )
    {
        if ( NO == self.searchCategoryModel.loaded )
        {
            [self presentLoadingTips:__TEXT(@"tips_loading")];
        }
    }
    else
    {
        [self dismissTips];
        [self dismissModalViewAnimated:YES];
    }
    
    if ( msg.succeed )
    {
        [self.list asyncReloadData];
    }
}

@end
