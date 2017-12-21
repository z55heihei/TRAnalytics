//
//  TRAnalytics.h
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRAnalyticsMacro.h"
#import "TRLocation.h"
#import "TRAnalyticsField.h"


@interface TRAnalytics : NSObject

AS_SINGLETON(TRAnalytics)

/**
 设置App版本号
 
 @param version 版本号
 */
+ (void)setAppVersion:(NSString *)version;

/**
 设置渠道
 
 @param channel 渠道
 */
+ (void)setChannel:(NSString *)channel;


/**
 设置发送策略
 
 @param policy 策略
 @param method 方法
 */
+ (void)setReportPolicy:(ReportPolicy)policy method:(NSString *)method;

/**
 设置是否开启捕获奔溃异常
 
 @param enable 是否捕获
 */
+ (void)setExceptCrashCatchEnable:(BOOL)enable;

/** 
 设定log上传服务器的频率
 @param second 单位为秒,最小90秒,最大86400秒(24hour).
 */
+ (void)setLogSendInterval:(double)second;

/** 设置经纬度信息
 
 @param latitude 纬度.
 @param longitude 经度.
 */
+ (void)setLatitude:(double)latitude longitude:(double)longitude;

/** 设置经纬度信息
 
 @param location CLLocation 经纬度信息
 */
+ (void)setLocation:(TRLocation *)location;

/**
 开始进入页面统计时间长度
 
 @param pageName 页面名称
 */
+ (void)beginLogPageView:(NSString *)pageName;

/**
 离开页面统计时间长度
 
 @param pageName 页面名称
 */
+ (void)endLogPageView:(NSString *)pageName;

/**
 页面统计时间
 
 @param interval 时间长度
 */
+ (void)logPageViewTimeInterval:(NSTimeInterval)interval;

/**
 统计事件
 
 @param eventId 事件id
 @param method 方法
 */
+ (void)event:(NSString *)eventId method:(NSString *)method;

/**
 统计事件带参数
 
 @param eventId 时间Id
 @param method 方法
 @param attributes 参数
 */
+ (void)event:(NSString *)eventId method:(NSString *)method attributes:(NSDictionary *)attributes;


@end
