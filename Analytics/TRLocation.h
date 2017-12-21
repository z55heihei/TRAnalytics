//
//  TRLocation.h
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface TRLocation : NSObject

/**
 纬度
 */
@property (nonatomic) double latitude;

/**
 经度
 */
@property (nonatomic) double longitude;

/**
 城市
 */
@property (nonatomic,copy) NSString    *city;

/**
 省份
 */
@property (nonatomic,copy) NSString    *province;

/**
 街道
 */
@property (nonatomic,copy) NSString    *street;

/**
 区
 */
@property (nonatomic,copy) NSString    *area;

@end

/**
 更新地理位置Block
 
 @param location 位置
 @param error 错误
 */
typedef void (^DidUpdateToLocationBlock)(TRLocation *location,NSError *error);

/**
 获取地理位置失败Block
 
 @param location 位置
 @param error 错误
 */
typedef void(^DidFailWithErrorBlock)(TRLocation *location, NSError *error);


@interface TRLocationManager : NSObject

/**
 位置实例属性
 */
@property (nonatomic,strong) TRLocation *location;

/**
 单例
 */
+ (instancetype)sharedInstance;

/**
 开始定位位置
 
 @param updateBlock 位置更新Block
 */
- (void)startAndDidUpdateToLocation:(DidUpdateToLocationBlock)updateBlock;

/**
 开始定位位置
 
 @param updateBlock 位置更新Block
 @param errorBlock 位置更新失败Block
 */
- (void)startAndDidUpdateToLocation:(DidUpdateToLocationBlock)updateBlock 
				   didFailWithError:(DidFailWithErrorBlock)errorBlock;


/**
 位置更新
 
 @param updateBlock 位置更新Block
 */
- (void)didUpdateToLocationBlock:(DidUpdateToLocationBlock)updateBlock;

/**
 定位位置失败
 
 @param errorBlock 位置更新失败Block
 */
- (void)didFailWithErrorWithBlock:(DidFailWithErrorBlock)errorBlock;

/**
 开始定位
 */
- (void)start;

/**
 停止定位
 */
- (void)stop;

/**
 是否打开隐私允许
 */
- (BOOL)isOpen;


@end

