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

#import "CommonPullLoader.h"
#import "CommonFootLoader.h"

#import "I0_PersonalListCell_iPhone.h"


#pragma mark -

@implementation I0_PersonalListBoard_iPhone

SUPPORT_RESOURCE_LOADING( YES )
SUPPORT_AUTOMATIC_LAYOUT( YES )

DEF_OUTLET( BeeUIScrollView, list )


DEF_MODEL( OrderModel, orderModel)





- (void)load
{
    self.orderModel = [OrderModel modelWithObserver:self];
    self.orderModel.type = ORDER_LIST_FINISHED;
}

- (void)unload
{
    SAFE_RELEASE_MODEL( self.orderModel );
}

#pragma mark -

ON_CREATE_VIEWS( signal )
{
    [self showNavigationBarAnimated:NO];
    
    self.navigationBarTitle=__TEXT(@"ecmobile");
    
    @weakify(self);
    
    
    $(@"#title").TEXT(__TEXT(@"purchased_list"));
    $(@"#title2").TEXT(__TEXT(@"personal_recommend"));
    
    
    self.list.headerClass = [CommonPullLoader class];
    self.list.headerShown = YES;
    
    self.list.footerClass = [CommonFootLoader class];
    self.list.footerShown = YES;

    self.list.lineCount = 4;
    self.list.animationDuration = 0.25f;
    self.list.width=self.list.width*0.9;

    
    self.list.whenReloading = ^
    {
        @normalize(self);
        
        int total = 0;
        
        NSMutableArray *personalList=[[NSMutableArray alloc]init];
        
        for ( int i = 0; i < self.orderModel.orders.count; i++ )
        {
            NSArray *goods_list=[NSArray arrayWithObject:[[self.orderModel.orders objectAtIndex:i] goods_list]];
            for (int j =0; j < goods_list.count; j++) {
                [personalList insertObject:[goods_list safeObjectAtIndex:j] atIndex:total];
                total += 1;
            }
        }
        
        self.list.total = total;
        
        
        for (int i =0; i < personalList.count; i++) {
                BeeUIScrollItem * item = self.list.items[i];
                item.clazz = [I0_PersonalListCell_iPhone  class];
                item.size = CGSizeMake( self.list.width/self.list.lineCount, (self.list.width/self.list.lineCount)*1.2 );
                item.data = [personalList safeObjectAtIndex:i];
                item.rule = BeeUIScrollLayoutRule_Tile;
        }

    };
    self.list.whenHeaderRefresh = ^
    {
        @normalize(self);
        
        [self.orderModel firstPage];
    };
    self.list.whenFooterRefresh = ^
    {
        @normalize(self);
        
        [self.orderModel nextPage];
    };
    self.list.whenReachBottom = ^
    {
        @normalize(self);
        
        [self.orderModel nextPage];
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
    
    [self.list reloadData];
}

ON_DID_APPEAR( signal )
{
    
    [self.orderModel firstPage];

}

ON_WILL_DISAPPEAR( signal )
{
    
    [self dismissModalViewAnimated:YES];
    
    [bee.ui.appBoard hideTabbar];
    
}

ON_DID_DISAPPEAR( signal )
{

}



#pragma mark -

//ON_MESSAGE3( API, category, msg )
//{
//    if ( msg.sending )
//    {
//        if ( NO == self.searchCategoryModel.loaded )
//        {
//            [self presentLoadingTips:__TEXT(@"tips_loading")];
//        }
//    }
//    else
//    {
//        [self dismissTips];
//        [self dismissModalViewAnimated:YES];
//    }
//    
//    if ( msg.succeed )
//    {
//        [self.list asyncReloadData];
//    }
//}

#pragma mark -

ON_MESSAGE3(API, order_list, msg)
{
    if ( msg.sending )
    {
        if ( NO == self.orderModel.loaded )
        {
            [self presentLoadingTips:__TEXT(@"tips_loading")];
        }
        
        if ( self.orderModel.orders.count )
        {
            [self.list setFooterLoading:YES];
        }
        else
        {
            [self.list setFooterLoading:NO];
        }
    }
    else
    {
        [self dismissTips];
        
        [self.list setHeaderLoading:NO];
        [self.list setFooterLoading:NO];
    }
    
    if ( msg.succeed )
    {
        STATUS * status = msg.GET_OUTPUT(@"status");
        
        if ( status && status.succeed.boolValue )
        {
            [self.list setFooterMore:self.orderModel.more];
            [self.list asyncReloadData];
        }
        else
        {
            [self presentFailureTips:msg.message];
        }
    }
    else if ( msg.failed )
    {
        [self presentFailureTips:msg.message];
    }

}

@end
