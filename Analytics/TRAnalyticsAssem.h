//
//  TRAnalyticsAssem.h
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TRAnalyticsMacro.h"

@class TRAnalyticsAssemPVMaker;

typedef TRAnalyticsAssemPVMaker *(^AssemPVMakerTypeBlock)(PVType type);
typedef TRAnalyticsAssemPVMaker *(^AssemPVMakerValueBlock)(NSString *value);

//PV统计所需要的字段(链式)
@interface TRAnalyticsAssemPVMaker : NSObject
/**
 pv类型
 */
@property (nonatomic,assign) PVType type;

/**
 产品id
 */
@property (nonatomic,copy) NSString *productId; 

/**
 标题
 */
@property (nonatomic,copy) NSString *title;

/**
 页面URL
 */
@property (nonatomic,copy) NSString *pageURL;


/**
 产品id block
 */
- (AssemPVMakerValueBlock)xproductId;

/**
 标题 block
 */
- (AssemPVMakerValueBlock)xtitle;

/**
 页面URL block
 */
- (AssemPVMakerValueBlock)xpageURL;

/**
 pv类型
 */
- (AssemPVMakerTypeBlock)xType;

/**
 统计数据组装
 */
+ (TRAnalyticsAssemPVMaker *)makeAssemPV:(void (^)(TRAnalyticsAssemPVMaker *maker))block;


@end

@interface TRAnalyticsAssem : NSObject

/**
 组装统计CLT
 */
+ (void)AssemCLT;

/**
 组装统计PV
 
 @param maker PV统计所需要的字段
 */
+ (void)AssemPVMaker:(TRAnalyticsAssemPVMaker *)maker;

/**
 组装统计PV
 
 @param type 
 应用类型(1)
 广告类型(2)
 活动类型(3)
 卡片类型(4)
 消息类型(5)
 分享类型(6)
 其他传递（9）
 
 @param maker 数据model
 */
+ (void)AssemPVType:(PVType)type maker:(TRAnalyticsAssemPVMaker *)maker;

/**
 组装统计PV
 
 @param type 
 应用类型(1)
 广告类型(2)
 活动类型(3)
 卡片类型(4)
 消息类型(5)
 分享类型(6)
 其他传递（9）
 
 @param maker 数据model
 @param control 控件
 */
+ (void)AssemPVType:(PVType)type maker:(TRAnalyticsAssemPVMaker *)maker control:(UIControl *)control;

@end
