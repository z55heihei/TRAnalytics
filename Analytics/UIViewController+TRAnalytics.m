//
//  UIViewController+TRAnalytics.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "UIViewController+TRAnalytics.h"
#import <objc/runtime.h>
#import "TRAnalytics.h"

@interface UIViewController ()

/**
 统计时间
 */
@property (nonatomic, strong) NSDate *ex_date;

@end

@implementation UIViewController (TRAnalytics)

+ (void)load{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SEL systemDidAppearSel = @selector(viewDidAppear:);
		SEL customDidAppearSel = @selector(TRAnalytics_viewDidAppear:);
		[self.class swizzleSystemSel:systemDidAppearSel implementationCustomSel:customDidAppearSel];
		
		SEL sysDidDisappearSel = @selector(viewDidDisappear:);
		SEL customwDidDisappearSel = @selector(TRAnalytics_viewDidDisappear:);
		[self.class swizzleSystemSel:sysDidDisappearSel implementationCustomSel:customwDidDisappearSel];
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


- (void)TRAnalytics_viewDidAppear:(BOOL )animated{
	[self TRAnalytics_viewDidAppear:animated];
	//记录开始时间
	[self setEx_date:[NSDate new]];
	
	//调用进入调用接口或者保存到数据库
	[TRAnalytics beginLogPageView:NSStringFromClass([self class])];
}

- (void)TRAnalytics_viewDidDisappear:(BOOL )animated{
	[self TRAnalytics_viewDidDisappear:animated];
	//记录离开时间
	NSDate *date = [NSDate new];
	
	//计算停留时间
	NSTimeInterval interval = [date timeIntervalSinceDate:self.ex_date];
	
	//设置页面log统计时间
	[TRAnalytics logPageViewTimeInterval:interval];
	
	//调用离开时候调用接口或者保存到数据库
	[TRAnalytics endLogPageView:NSStringFromClass([self class])];
}

- (NSDate *)ex_date{
	return  objc_getAssociatedObject(self, _cmd);
}

- (void)setEx_date:(NSDate *)ex_date{
	objc_setAssociatedObject(self, @selector(ex_date), ex_date, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TRAnalyticsAssemPVMaker *)pvmaker{
	return objc_getAssociatedObject(self, _cmd);
}

- (void)setPvmaker:(TRAnalyticsAssemPVMaker *)pvmaker{
	objc_setAssociatedObject(self, @selector(pvmaker), pvmaker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
