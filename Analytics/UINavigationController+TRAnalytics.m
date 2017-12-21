//
//  UINavigationController+TRAnalytics.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "UINavigationController+TRAnalytics.h"
#import "TRAnalyticsAssem.h"
#import <objc/runtime.h>
#import "UIViewController+TRAnalytics.h"

@implementation UINavigationController (TRAnalytics)

- (UIViewController *)analytics_popViewControllerAnimated:(BOOL)animated{
	[TRAnalyticsAssemPVMaker makeAssemPV:^(TRAnalyticsAssemPVMaker *maker) {
		maker.xtitle(self.topViewController.title).xpageURL(NSStringFromClass([self.topViewController class])).xType(kPVTypeBack);
		[TRAnalyticsAssem AssemPVMaker:maker];
	}];	
	return [self analytics_popViewControllerAnimated:animated];
}

- (void)analytics_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
	TRAnalyticsAssemPVMaker *maker = viewController.pvmaker;
	if (maker) {
		[TRAnalyticsAssem AssemPVMaker:maker];
	}else{
		if (self.viewControllers.count > 0) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[TRAnalyticsAssemPVMaker makeAssemPV:^(TRAnalyticsAssemPVMaker *maker) {
					maker.xtitle(viewController.title).xpageURL(NSStringFromClass([viewController class])).xType(kPVTypeElse);
					[TRAnalyticsAssem AssemPVMaker:maker];
				}];
			});	
		}
	}
	[self analytics_pushViewController:viewController animated:animated];
}

- (void)PVMake:(UIViewController *)viewController push:(BOOL)push{
	
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

+ (void)load{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self.class swizzleSystemSel:@selector(popViewControllerAnimated:) implementationCustomSel:@selector(analytics_popViewControllerAnimated:)];
		[self.class swizzleSystemSel:@selector(pushViewController:animated:) implementationCustomSel:@selector(analytics_pushViewController:animated:)];
	});
}

@end
