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

#import "AppDelegate.h"
#import "AppBoard_iPad.h"
#import "AppBoard_iPhone.h"

#import "controller.h"
#import "model.h"
#import "ecmobile.h"
#import "MobClick.h"

#import "bee.services.alipay.h"
#import "bee.services.location.h"
#import "bee.services.share.weixin.h"
#import "bee.services.share.sinaweibo.h"
#import "bee.services.share.tencentweibo.h"
#import "bee.services.wizard.h"
#import "bee.services.siri.h"
#import "bee.services.uppayplugin.h"

@implementation AppDelegate

#pragma mark -

- (void)load
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO];

	bee.ui.config.ASR = YES;		// Signal自动路由
	bee.ui.config.iOS6Mode = YES;	// iOS6.0界面布局

	[[BeeUITemplateManager sharedInstance] preloadResources];
	[[BeeUITemplateManager sharedInstance] preloadPackages];

	[ArticleGroupModel	sharedInstance];
	[BannerModel		sharedInstance];
	[CartModel			sharedInstance];
	[CategoryModel		sharedInstance];
	[ConfigModel		sharedInstance];
	[UserModel			sharedInstance];

	// 配置ECSHOP
	[ServerConfig sharedInstance].url = @"http://120.24.79.27/ecmobile/?url=";

	// 配置闪屏
//	bee.services.wizard.config.showBackground = YES;
//	bee.services.wizard.config.showPageControl = YES;
//	bee.services.wizard.config.backgroundImage = [UIImage imageNamed:@"tuitional_bg.jpg"];
//	bee.services.wizard.config.pageDotSize = CGSizeMake( 11.0f, 11.0f );
//	bee.services.wizard.config.pageDotNormal = [UIImage imageNamed:@"tuitional-carousel-active-btn.png"];
//	bee.services.wizard.config.pageDotHighlighted = [UIImage imageNamed:@"tuitional-carousel-btn.png"];
//	bee.services.wizard.config.pageDotLast = [UIImage imageNamed:@"tuitional-carousel-btn-last.png"];
//
//	bee.services.wizard.config.splashes[0] = @"wizard_1.xml";
//	bee.services.wizard.config.splashes[1] = @"wizard_2.xml";
//	bee.services.wizard.config.splashes[2] = @"wizard_3.xml";
//	bee.services.wizard.config.splashes[3] = @"wizard_4.xml";
//	bee.services.wizard.config.splashes[4] = @"wizard_5.xml";
    
	// 配置提示框
	{
		[BeeUITipsCenter setDefaultContainerView:self.window];
		[BeeUITipsCenter setDefaultBubble:[UIImage imageNamed:@"alertBox.png"]];
		[BeeUITipsCenter setDefaultMessageIcon:[UIImage imageNamed:@"icon.png"]];
		[BeeUITipsCenter setDefaultSuccessIcon:[UIImage imageNamed:@"icon.png"]];
		[BeeUITipsCenter setDefaultFailureIcon:[UIImage imageNamed:@"icon.png"]];
	}

	// 配置导航条
	{
		[BeeUINavigationBar setTitleColor:[UIColor whiteColor]];
		[BeeUINavigationBar setBackgroundColor:[UIColor blackColor]];
		
		if ( IOS7_OR_LATER )
		{
			[BeeUINavigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg_iphone5.png"]];
		}
		else
		{
			[BeeUINavigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"]];
		}
	}
	
	[self updateConfig];
	
	self.window.rootViewController = [AppBoard_iPhone sharedInstance];
	
	[MobClick appLaunched];
}

- (void)unload
{
	[self unobserveAllNotifications];

	[MobClick appTerminated];
}

#pragma mark -

- (void)updateConfig
{
	//ALIAS( bee.services.share.weixin,		weixin );
	//ALIAS( bee.services.share.tencentweibo,	tweibo );
	//ALIAS( bee.services.share.sinaweibo,	sweibo );
	ALIAS( bee.services.alipay,				alipay );
//	ALIAS( bee.services.siri,				siri );
	ALIAS( bee.services.location,			lbs );

	// 配置微信
//	weixin.config.appId			= @"<Your weixinID>";
//	weixin.config.appKey		= @"<Your weixinKey>";
	
	// 配置新浪
//	sweibo.config.appKey		= @"29894543";
//	sweibo.config.appSecret		= @"8cb17358d7ddc0f88ff556a4a7a5e387";
//	sweibo.config.redirectURI	= @"https://api.weibo.com/oauth2/default.html";
	
	// 配置腾讯
//	tweibo.config.appKey		= @"<Your tencentWeiboKey>";
//	tweibo.config.appSecret		= @"<Your tencentWeiboSecret>";
//	tweibo.config.redirectURI	= @"<Your tencentWeiboCallback>";
	
	// 配置支付宝
	alipay.config.parnter		= @"<Your alipayPartnerID>";
	alipay.config.seller		= @"<Your alipaySeller>";
	alipay.config.privateKey	= @"<Your alipayPrivateKey>";
	alipay.config.publicKey		= @"<Your alipayPublicKey>";
	alipay.config.notifyURL		= @"<Your alipayCallback>";
	alipay.config.wapCallBackURL	= @"<Your alipayWapURL>";

	// 配置语音识别
	//siri.config.showUI			= NO;
	//siri.config.appID			= @"54af7cd2";

	// 配置友盟
	[MobClick setAppVersion:[BeeSystemInfo appShortVersion]];
	[MobClick setCrashReportEnabled:YES];
	[MobClick setLatitude:lbs.location.coordinate.latitude longitude:lbs.location.coordinate.longitude];
	[MobClick setLocation:lbs.location];
	[MobClick startWithAppkey:@"54b39602fd98c59468000d58" reportPolicy:BATCH channelId:nil];
	
	// 配置快递100
	//[ExpressModel setKuaidi100Key:@"<Your kuaidi100Key>"];
}

@end
