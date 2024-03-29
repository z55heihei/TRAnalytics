//
//  UIControl+TRAnalytics.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "UIControl+TRAnalytics.h"
#import "TRAnalytics.h"
#import <objc/runtime.h>

//事件Id的key
static const void *eventIdIdentifierKey = &eventIdIdentifierKey;
//事件参数的key
static const void *eventAttributesIdentifierKey = &eventAttributesIdentifierKey;
//接口服务方法key
static const void *eventMethodIdentifierKey = &eventMethodIdentifierKey;

@interface UIControl ()

/**
 事件Id
 */
@property (nonatomic, strong) NSString *eventId;

/**
 接口服务方法
 */
@property (nonatomic, strong) NSString *method;

/**
 事件参数
 */
@property (nonatomic, strong) NSDictionary *attributes;

@end


@implementation UIControl (TRAnalytics)
+ (void)load{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SEL originalSelector = @selector(sendAction:to:forEvent:);
		SEL swizzledSelector = @selector(exanalytics_sendAction:to:forEvent:);
		[UIControl swizzleSystemSel:originalSelector implementationCustomSel:swizzledSelector];
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


- (void)exanalytics_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;{
	[self performUserStastisticsAction:action to:target forEvent:event];
	[self exanalytics_sendAction:action to:target forEvent:event];
}

- (void)performUserStastisticsAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;{
	if ([[[event allTouches] anyObject] phase] == UITouchPhaseEnded) {
		//判断是否有事件Id
		if (self.eventId) {
			//判断是否有事件Id带事件参数
			if (self.attributes) {
				//调用进入调用接口或者保存到数据库
				[TRAnalytics event:self.eventId method:self.method attributes:self.attributes];
			}else{
				//调用进入调用接口或者保存到数据库
				[TRAnalytics event:self.eventId method:self.method];
			}
		}
	}
}

- (NSString *)eventId {
	return objc_getAssociatedObject(self, eventIdIdentifierKey);
}

- (void)setEventId:(NSString *)eventId{
	objc_setAssociatedObject(self, eventIdIdentifierKey, eventId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)method{
	return objc_getAssociatedObject(self, eventMethodIdentifierKey);
}

- (void)setMethod:(NSString *)method{
	objc_setAssociatedObject(self, eventMethodIdentifierKey, method, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)attributes{
	return objc_getAssociatedObject(self, eventAttributesIdentifierKey);
}

- (void)setAttributes:(NSDictionary *)attributes{
	objc_setAssociatedObject(self, eventAttributesIdentifierKey, attributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)event:(NSString *)eventId method:(NSString *)method{
	if (eventId) {
		self.eventId = eventId;
	}
	if (method) {
		self.method = method;
	}
}

- (void)event:(NSString *)eventId method:(NSString *)method attributes:(NSDictionary *)attributes{
	if (eventId) {
		self.eventId = eventId;
	}
	if (method) {
		self.method = method;
	}
	if (attributes) {
		self.attributes = attributes;
	}
}
@end
