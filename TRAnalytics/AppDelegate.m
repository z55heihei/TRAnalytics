//
//  AppDelegate.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "AppDelegate.h"
#import "TRAnalytics.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Override point for customization after application launch.
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];  	
	NSString *appVersion = infoDictionary[@"CFBundleDisplayName"];  
	//设置版本号
	[TRAnalytics setAppVersion:appVersion];
	//设置渠道
	[TRAnalytics setChannel:@"AppStore"];
	//设置打开崩溃开关
	[TRAnalytics setExceptCrashCatchEnable:YES];
	//发送策略
	[TRAnalytics setReportPolicy:REALTIME method:CLT];
	[TRAnalytics setReportPolicy:SEND_INTERVAL method:PV];
	[TRAnalytics setReportPolicy:BATCH method:CRS];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
