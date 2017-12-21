//
//  WKWebView+TRAnalytics.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "WKWebView+TRAnalytics.h"
#import "TRAnalyticsAssem.h"
#import <objc/runtime.h>

@implementation WKWebView (TRAnalytics)
- (WKNavigation *)analytics_goBack{
	[TRAnalyticsAssemPVMaker makeAssemPV:^(TRAnalyticsAssemPVMaker *maker) {
		[TRAnalyticsAssem AssemPVType:kPVTypeBack maker:maker];
	}];
	return [self analytics_goBack];
}

+ (void)load{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self.class swizzleSystemSel:@selector(goBack) implementationCustomSel:@selector(analytics_goBack)];
	});
}

+ (void)swizzleSystemSel:(SEL)systemSel implementationCustomSel:(SEL)customSel{
	Class cls = [self class];
	Method systemMethod = class_getInstanceMethod(cls, systemSel);
	Method customMethod = class_getInstanceMethod(cls, customSel);
	
	// BOOL class_addMethod(Class cls, SEL name, IMP imp,const char *types) cls被添加方法的类，name: 被增加Method的name, imp 被添加的Method的实现函数，types被添加Method的实现函数的返回类型和参数的字符串
	BOOL didAddMethod = class_addMethod(cls, systemSel, method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
	if (didAddMethod){
		class_replaceMethod(cls, customSel, method_getImplementation(systemMethod), method_getTypeEncoding(customMethod));
	}else{
		method_exchangeImplementations(systemMethod, customMethod);
	}
}

@end
