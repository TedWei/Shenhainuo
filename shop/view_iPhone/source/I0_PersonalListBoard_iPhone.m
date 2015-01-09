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

#import "B2_ProductDetailBoard_iPhone.h"


#pragma mark -

@implementation I0_PersonalListBoard_iPhone

SUPPORT_RESOURCE_LOADING( YES )
SUPPORT_AUTOMATIC_LAYOUT( YES )

DEF_MODEL( OrderModel, orderModel)

DEF_MODEL( CategoryModel, categoryModel)

DEF_OUTLET( BeeUIScrollView, list )

DEF_OUTLET( BeeUIScrollView, list2 )


- (void)load
{
    self.categoryModel = [CategoryModel modelWithObserver:self];
    self.orderModel = [OrderModel modelWithObserver:self];
    self.orderModel.type = ORDER_LIST_FINISHED;
}

- (void)unload
{
    SAFE_RELEASE_MODEL( self.orderModel );
    SAFE_RELEASE_MODEL( self.categoryModel );
}

#pragma mark -

ON_CREATE_VIEWS( signal )
{
    [self showNavigationBarAnimated:NO];
    
    self.navigationBarTitle=__TEXT(@"ecmobile");
    
    @weakify(self);
    
    
    $(@"#title").TEXT(__TEXT(@"purchased_list"));
    $(@"#title2").TEXT(__TEXT(@"personal_recommend"));
    
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
                [personalList insertObject:[[goods_list safeObjectAtIndex:j] safeObjectAtIndex:0] atIndex:total];
                total += 1;
            }
        }
        
        self.list.total = total;
        
        for (int i =0; i < personalList.count; i++) {
                BeeUIScrollItem * item = self.list.items[i];
                item.clazz = [I0_PersonalListCell_iPhone  class];
                item.size = CGSizeMake( self.list.width/self.list.lineCount, (self.list.width/self.list.lineCount)*1.1 );
                item.data = [personalList safeObjectAtIndex:i];
                item.rule = BeeUIScrollLayoutRule_Tile;
        }
    };
    
    
    self.list2.lineCount = 4;
    self.list2.animationDuration = 0.25f;
    self.list2.width=self.list.width*0.9;
    
    
    self.list2.whenReloading = ^
    {
        @normalize(self);
        
        int total = 0;
        
        NSMutableArray *categoryRecommendList=[[NSMutableArray alloc]init];
        
        for ( int i = 0; i < self.categoryModel.categories.count; i++ )
        {
            NSArray *goods_list=[NSArray arrayWithObject:[[self.categoryModel.categories objectAtIndex:i] goods]];
            if ( goods_list.count > 0 )
            {
             
              for (int j =0; j < goods_list.count; j++) {
                  NSArray * goods=[goods_list safeObjectAtIndex:j];
                  if (  goods.count > 0 )
                  {
                      for (int z = 0; z < goods.count; z++) {
                          [categoryRecommendList insertObject:[goods safeObjectAtIndex:z] atIndex:total];
                          total += 1;
                      }
                  }
              }
            }
        }
                
        self.list2.total = total;
        
        for (int i =0; i < categoryRecommendList.count; i++) {
            BeeUIScrollItem * item = self.list2.items[i];
            item.clazz = [I0_PersonalListCell_iPhone  class];
            item.size = CGSizeMake( self.list.width/self.list.lineCount, (self.list.width/self.list.lineCount)*1.1 );
            item.data = [categoryRecommendList safeObjectAtIndex:i];
            item.rule = BeeUIScrollLayoutRule_Tile;
        }

    };
}

ON_DELETE_VIEWS( signal )
{
    
    self.list = nil;
    
    self.list2 = nil;
}

ON_LAYOUT_VIEWS( signal )
{
}

ON_WILL_APPEAR( signal )
{
    [self.list reloadData];
    [self.list2 reloadData];
    
    [bee.ui.appBoard showTabbar];
    
}

ON_DID_APPEAR( signal )
{
    
    [self.orderModel firstPage];
    
    if ( NO == self.categoryModel.loaded )
    {
        [self.categoryModel reload];
    }

}

ON_WILL_DISAPPEAR( signal )
{
    
    [self dismissModalViewAnimated:YES];
    
    [bee.ui.appBoard hideTabbar];
    
}

ON_DID_DISAPPEAR( signal )
{

}


ON_LOAD_DATAS( signal )
{
    [self.categoryModel loadCache];
//    [self.orderModel loadCache];
}

#pragma mark -

ON_SIGNAL3(I0_PersonalListCell_iPhone, mask,  signal )
{
    SIMPLE_GOODS * goods = signal.sourceCell.data;
    
    if ( goods )
    {
        B2_ProductDetailBoard_iPhone * board = [B2_ProductDetailBoard_iPhone board];
        board.goodsModel.goods_id = goods.goods_id ? goods.goods_id : goods.id;
        [self.stack pushBoard:board animated:YES];
    }
}



#pragma mark -

ON_MESSAGE3(API, order_list, msg)
{
    if ( msg.sending )
    {
        if ( NO == self.orderModel.loaded )
        {
            [self presentLoadingTips:__TEXT(@"tips_loading")];
        }
        
    }
    else
    {
        [self dismissTips];
        
    }
    
    if ( msg.succeed )
    {
        STATUS * status = msg.GET_OUTPUT(@"status");
        
        if ( status && status.succeed.boolValue )
        {
            [self.list asyncReloadData];
        }
        else
        {
            [self showErrorTips:msg];
        }
    }
    else if ( msg.failed )
    {
        [self showErrorTips:msg];
    }

}

#pragma mark -

ON_MESSAGE3( API, home_data, msg )
{
    if ( msg.sending )
    {
        //		if ( NO == self.bannerModel.loaded && 0 == self.bannerModel.banners.count )
        //		{
        //			[self presentLoadingTips:__TEXT(@"tips_loading")];
        //		}
    }
    else
    {
        [self.list2 setHeaderLoading:NO];
        
        [self dismissTips];
        
        if ( msg.succeed )
        {
            [self.list2 asyncReloadData];
        }
        else if ( msg.failed )
        {
            [self showErrorTips:msg];
        }
    }
}

@end
