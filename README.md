# TRAnalytics

#### TRAnalytics 统计类

	//设置版本号
	[TRAnalytics setAppVersion:@"v1.0"];
	
	//设置渠道
	[TRAnalytics setChannel:@"AppStore"];
	
	//设置打开崩溃开关
	[TRAnalytics setExceptCrashCatchEnable:YES];
	
	//发送策略
	[TRAnalytics setReportPolicy:REALTIME method:CLT];
	[TRAnalytics setReportPolicy:SEND_INTERVAL method:PV];
	[TRAnalytics setReportPolicy:BATCH method:CRS];

```
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

```

#### TRAnalyticsField 统计参数类

#### TRAnalyticsRequest 请求数据类

#### TRAnalyticsField 统计参数类

#### TRAnalyticsAssem 数据组装类（链式写法）

	[TRAnalyticsAssem AssemPVMaker:[TRAnalyticsAssemPVMaker makeAssemPV:^(TRAnalyticsAssemPVMaker *maker) {
		maker.xtitle(@"测试")
		.xpageURL(NSStringFromClass([ViewController class]))
		.xType(kPVTypeVenderApp)
		.xproductId(@"2300283082830")
	}] ];

```
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
```

#### UIKit+Category: 
#### UIControl+TRAnalytics (控件点击统计插码)
#### UIViewController+EXAnalytics （页面访问统计插码，停留时间统计）
#### UINavigationController+EXAnalytics (导航栏，push、pop等统计插码)
#### WKWebView+EXAnalytics (浏览器统计插码)


