//
//  I0_PersonalListBoard_iPhone.h
//  shop
//
//  Created by weited on 1/6/15.
//  Copyright (c) 2015 geek-zoo studio. All rights reserved.
//

#import "Bee.h"
#import "model.h"
#import "BaseBoard_iPhone.h"

@class I0_PersonalListBoard_iPhone;

@interface I0_PersonalListBoard_iPhone : BaseBoard_iPhone

AS_OUTLET( BeeUIScrollView, list )

AS_MODEL( OrderModel, orderModel)



@end