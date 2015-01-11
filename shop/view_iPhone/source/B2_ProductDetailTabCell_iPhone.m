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
//	Powered by BeeFramework
//

#import "B2_ProductDetailTabCell_iPhone.h"

#pragma mark -

@implementation B2_ProductDetailTabCell_iPhone

SUPPORT_AUTOMATIC_LAYOUT( YES )
SUPPORT_RESOURCE_LOADING( YES )

DEF_OUTLET( BeeUILabel, purchased)

- (void)load
{
    $(@"#purchased").TEXT(__TEXT(@"purchased_product"));
    $(@"#add").HIDE();
    $(@"#buy").HIDE();
    $(@"#purchased").HIDE();
	$(@"#badge-bg").HIDE();
	$(@"#badge").HIDE();
    
}

ON_DID_APPEAR( signal )
{
  
    
}

ON_CREATE_VIEWS( signal ){

}



- (void)unload
{

}

- (void)dataDidChanged
{
    
	NSNumber * count = self.data;
    
	
	if ( count && count.intValue > 0 )
	{
		$(@"#badge-bg").SHOW();
		$(@"#badge").SHOW().DATA( count );
	}
	else
	{
		$(@"#badge-bg").HIDE();
		$(@"#badge").HIDE();
	}
}



@end
