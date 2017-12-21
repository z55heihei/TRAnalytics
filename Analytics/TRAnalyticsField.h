//
//  TRAnalyticsField.h
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - 公共参数Model，部分接口按调用频率存储
#pragma mark - 
@interface CommonField : NSObject

/**
 区域编码(区域编码)
 */
@property (nonatomic,copy) NSString *areaCode;

/**
 访问时间（YYYY-MM-DD HH24:MI:SS必填）
 */
@property (nonatomic,copy) NSString *date;

/**
 访问用户ID(登陆用户ID)
 */
@property (nonatomic,copy) NSString *userId;

/**
 客户端唯一标志(用户标识COOKIES/IMEI/唯一标志)	安桌填写imei Ios填写唯一标志
 */
@property (nonatomic,copy) NSString *idfa;

/**
 手机号码（此手机号码取硬件手机号码，非登陆用户手机号码，安桌能获取的必需填写，ios不能获取时可以填空）
 */
@property (nonatomic,copy) NSString *phone;

/**
 手机型号
 */
@property (nonatomic,copy) NSString *phoneType;

/**
 手机操作系统
 */
@property (nonatomic,copy) NSString *os;

/**
 手机分辨率
 */
@property (nonatomic,copy) NSString *pixel;

/**
 渠道Id
 */
@property (nonatomic,copy) NSString *channel;

/**
 终端ip
 */
@property (nonatomic,copy) NSString *ip;

/**
 客户端版本
 */
@property (nonatomic,copy) NSString *version;

/**
 WIFI标志 当前登录网络标志，填写如下类型(1，2，3，4，5中的一个)：1-2G 2-3G 3-4G 4-WIFI 9-未知
 */
@property (nonatomic,copy) NSString *netstatus;

/**
 客户端类型 1-安卓，2-IOS
 */
@property (nonatomic,copy) NSString *client;

/**
 运营商名称
 */
@property (nonatomic,copy) NSString *carrier;

/**
 sim卡序列号
 */
@property (nonatomic,copy) NSString *simIds;

/**
 IMSI
 */
@property (nonatomic,copy) NSString *imsi;

/**
 sim卡所在国家
 */
@property (nonatomic,copy) NSString *imsiArea;


@end

#pragma mark - 继承TRAnalyticsField公参，PV拓展字段
#pragma mark -

@interface PVField : CommonField

/**
 事件Id
 */
@property (nonatomic,copy) NSString *eventId;

/**
 页面地址(H5的URL，或者客户端页面报名地址)
 */
@property (nonatomic,copy) NSString *pageURL; 

/**
 页面类型枚举：	应用ID(1) 广告Id(2) 活动ID(3) 卡片ID(4) 其他传递（9
 */
@property (nonatomic,copy) NSString *pageType; 

/**
 页面名称（页面TITLE，客户端无明确连接的建议都添加上）
 */
@property (nonatomic,copy) NSString *pageName; 

/**
 访问平台类型(1:安卓，2:IOS，3:WEB，4：WAP)
 */
@property (nonatomic,copy) NSString *platform;

@end

#pragma mark - 继承TRAnalyticsField公参，CRS拓展字段
#pragma mark -

@interface CRSField : CommonField

/**
 异常奔溃信息
 */
@property (nonatomic,copy) NSString *crash;

@end


@interface TRAnalyticsField : NSObject

@end
