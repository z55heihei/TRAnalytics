//
//  TRAnalyticsMacro.h
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#ifndef TRAnalyticsMacro_h
#define TRAnalyticsMacro_h

#pragma mark - 统计类型

typedef NS_ENUM(NSInteger, PVType) {
	kPVTypeVenderApp = 1,
	kPVTypeAd = 2,
	KPVTypePromotion = 3,
	kPVTypeGrid = 4,
	kPVTypeMessage = 5,
	kPVTypeShare = 6,
	kPVTypeClose = 7,
	kPVTypeBack = 8,
	kPVTypeElse = 9,
	kPVTypeBill = 10,
};

#pragma mark - 统计操作平台

typedef NS_ENUM(NSInteger, PVPlatType) {
	kPVPlatTypeIOS,
	kPVPlatTypeWEB,
	kPVPlatTypeWAP,
};


#pragma mark - 统计发送策略

typedef NS_ENUM(NSInteger, ReportPolicy) {
	REALTIME = 0,       //实时发送              (只在“集成测试”设备的DEBUG模式下有效)
	BATCH = 1,          //启动发送
	SEND_INTERVAL,  //最小间隔发送           ([90-86400]s, default 90s)
};

/**
 客户端时和登陆系统日志
 客户端属性标记接口:用户进入客户端时和登陆系统时，客户端均需要生成一行客户端属性日志，实时上传到服务器。
 */
#define CLT                             @"/apprdeds/ds/clt.do"

/**
 页面访问日志
 上报频率要求：
 1)：进入应用首页，必须实时报一次。
 2)：其他接口按照频次如满10次报一次
 3)：停留1分钟报一次（存在访问日志时，上报）
 
 上报触点要求：
 1)：所有页面。
 2)：点击后弹出层。
 3)：点击后需要请求服务器的地方（这时可能服务器返回状态，客户端为跳出框或者刷新父级页面）。
 */
#define PV                              @"/apprdeds/ds/pv.do"

/**
 奔溃日志
 */
#define CRS                             @"/apprdeds/ds/crs.do"


#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__                  = [[__class alloc] init]; } ); \
return __singleton__; \
}

#undef  RE_SINGLETON
#define RE_SINGLETON(__class) [__class sharedInstance]

#endif /* TRAnalyticsMacro_h */
