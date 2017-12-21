//
//  UIControl+TRAnalytics.h
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (TRAnalytics)

/**
 统计事件
 
 @param eventId 事件id
 @param method 方法
 */
- (void)event:(NSString *)eventId method:(NSString *)method;

/**
 统计事件带参数
 
 @param eventId 时间Id
 @param method 方法
 @param attributes 参数
 */
- (void)event:(NSString *)eventId method:(NSString *)method attributes:(NSDictionary *)attributes;

@end
