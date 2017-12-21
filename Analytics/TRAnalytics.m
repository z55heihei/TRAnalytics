//
//  TRAnalytics.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "TRAnalytics.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <sys/sysctl.h>
#import "sys/utsname.h" 
#import <UIKit/UIKit.h>


static NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
static NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
static NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

static NSString * const AnalyticsVersionKey = @"AnalyticsVersionKey";

static NSString * const AnalyticsChannelKey = @"AnalyticsChannelKey";


volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

void HandleException(NSException *exception);
void SignalHandler(int signal);


@interface TRAnalytics ()
/**
 地理位置
 */
@property (nonatomic,strong) TRLocation *location;

/**
 时间间隔
 */
@property (nonatomic,assign) NSTimeInterval interval;

/**
 统计共同参数
 */
@property (nonatomic,strong) CommonField *field;

/**
 pv参数
 */
@property (nonatomic,strong) PVField *pvField;

/**
 奔溃参数
 */
@property (nonatomic,strong) CRSField *crsField;

@end

@implementation TRAnalytics

DEF_SINGLETON(TRAnalytics)

#pragma mark - Field
#pragma mark - 

- (CommonField *)field{
	if (!_field) {
		_field = [[CommonField alloc] init];
	}
	return _field;
}

- (PVField *)pvField{
	if (!_pvField) {
		_pvField = [[PVField alloc] init];
	}
	return _pvField;
}

- (CRSField *)crsField{
	if (!_crsField) {
		_crsField = [[CRSField alloc] init];
	}
	return _crsField;
}


- (void)dealloc{
	
}

#pragma mark - setting configures
#pragma mark - 

+ (void)setAppVersion:(NSString *)version{
	if (version) {
		[[NSUserDefaults standardUserDefaults] setObject:version forKey:AnalyticsVersionKey];
		[[NSUserDefaults standardUserDefaults] synchronize];		
	}
}

+ (void)setChannel:(NSString *)channel{
	if (channel) {
		[[NSUserDefaults standardUserDefaults] setObject:channel forKey:AnalyticsChannelKey];
		[[NSUserDefaults standardUserDefaults] synchronize];		
	}
}

+ (void)setReportPolicy:(ReportPolicy)policy method:(NSString *)method{
	//开机时候传上到服务端
	if (policy == BATCH) {
		//奔溃记录上传到服务端
		[RE_SINGLETON(TRAnalytics) CRSRequests];
	}
	//定时记录
	if (policy == SEND_INTERVAL) {
		//GCD定时，1分钟后检测有统计更新就上传
		dispatch_block_t action = ^{
			//服务请求，数据上报都服务端
			[RE_SINGLETON(TRAnalytics) PVRequests];
		};
		[RE_SINGLETON(TRAnalytics) scheduleDispatchTimeInterval:60 queue:nil repeats:YES action:action];
	}
}

+ (void)setLocation:(TRLocation *)location{
	RE_SINGLETON(TRAnalytics).location = location;
}

+ (void)setLatitude:(double)latitude longitude:(double)longitude{
	//经度纬度传入
	RE_SINGLETON(TRAnalytics).location.latitude = longitude;
	RE_SINGLETON(TRAnalytics).location.latitude = latitude;
}

+ (void)setLogSendInterval:(double)second{
	//设置间隔最高时间
}

+ (void)setExceptCrashCatchEnable:(BOOL)enable{
	NSSetUncaughtExceptionHandler(enable ? HandleException : NULL);
	signal(SIGABRT, enable ? SignalHandler : SIG_DFL);
	signal(SIGILL, enable ? SignalHandler : SIG_DFL);
	signal(SIGSEGV, enable ? SignalHandler : SIG_DFL);
	signal(SIGFPE, enable ? SignalHandler : SIG_DFL);
	signal(SIGBUS, enable ? SignalHandler : SIG_DFL);
	signal(SIGPIPE, enable ? SignalHandler : SIG_DFL);
}

+ (void)beginLogPageView:(NSString *)pageName{
	//调用进入调用接口或者保存到数据库
}

+ (void)endLogPageView:(NSString *)pageName{
	//调用离开时候调用接口或者保存到数据库
}

+ (void)event:(NSString *)eventId method:(NSString *)method{
	NSLog(@"点击事件打点统计 点击事件Id ＝%@ 接口服务方法：method=%@",eventId,method);
	//事件点击统计，保存到数据库或者上传服务
	[RE_SINGLETON(TRAnalytics) sendDataMethod:method eventId:eventId attributes:nil];
}

+ (void)event:(NSString *)eventId method:(NSString *)method attributes:(NSDictionary *)attributes{
	NSLog(@"点击事件打点统计 点击事件Id ＝%@ 事件参数attributes =%@ 接口服务方法：method=%@",eventId,attributes,method);
	//事件点击统计，保存到数据库或者上传服务，带参数
	[RE_SINGLETON(TRAnalytics) sendDataMethod:method eventId:eventId attributes:attributes];
}

+ (void)logPageViewTimeInterval:(NSTimeInterval)interval{
	RE_SINGLETON(TRAnalytics).interval = interval;
}

#pragma mark - send data to server
#pragma mark -

- (void)sendDataMethod:(NSString *)method 
			   eventId:(NSString *)eventId 
			attributes:(NSDictionary *)attributes{
	//客户端时和登陆系统日志
	if ([method isEqualToString:CLT]) {
		[self CLTRequest];
	}
	//页面访问日志
	if ([method isEqualToString:PV]) {
		[self PVRequests];
	}
}

- (void)CLTRequest{
	//提交到服务端
	//TODO
}

- (void)PVRequests{
	//取前10条数据
	//提交到服务端
	//TODO
}

- (void)PVRequest:(PVField *)field{
	//提交到服务端
	//TODO
}

- (void)CRSRequests{
	//获取数据库表中的奔溃记录
	//提交到服务端
	//TODO
}


#pragma mark - App Run Time 
#pragma mark -

- (void)scheduleDispatchTimeInterval:(double)interval queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)action{
	//默认为全局并发队列
	if (nil == queue) {
		queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	}
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
	dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
	dispatch_source_set_timer(timer, start, interval * NSEC_PER_SEC, 0);
	dispatch_source_set_event_handler(timer, ^{
		if (action) {
			action();
		}
		//如果你重复，只执行一次，取消定时
		if (!repeats) {
			dispatch_source_cancel(timer);
		}
	});
	//启动定时器
	dispatch_resume(timer);
}


#pragma mark - UncaughtExceptionHandler 
#pragma mark -

void HandleException(NSException *exception) {
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	//如果太多不用处理
	if (exceptionCount > UncaughtExceptionMaximum) {
		return;
	}
	//获取调用堆栈
	NSArray *callStack = [exception callStackSymbols];
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
	
	//在主线程中，执行制定的方法, withObject是执行方法传入的参数
	NSException *except = [NSException exceptionWithName:[exception name]
												  reason:[exception reason]
												userInfo:userInfo];
	[[[TRAnalytics alloc] init] performSelectorOnMainThread:@selector(handleException:)
												 withObject:except
											  waitUntilDone:YES];
}

void SignalHandler(int signal) {
	//处理signal报错
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	// 如果太多不用处理
	if (exceptionCount > UncaughtExceptionMaximum) {
		return;
	}
	
	NSString* description = nil;
	switch (signal) {
		case SIGABRT:
			description = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
			break;
		case SIGILL:
			description = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
			break;
		case SIGSEGV:
			description = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
			break;
		case SIGFPE:
			description = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
			break;
		case SIGBUS:
			description = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
			break;
		case SIGPIPE:
			description = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
			break;
		default:
			description = [NSString stringWithFormat:@"Signal %d was raised!",signal];
	}
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	NSArray *callStack = [TRAnalytics backtrace];
	[userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
	[userInfo setObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
	
	//在主线程中，执行指定的方法, withObject是执行方法传入的参数
	[[[TRAnalytics alloc] init]
	 performSelectorOnMainThread:@selector(handleException:)
	 withObject:
	 [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
							 reason: description
						   userInfo: userInfo]
	 waitUntilDone:YES];
}

//获取调用堆栈
+ (NSArray *)backtrace {
	//指针列表
	void* callstack[128];
	//backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
	//128用来指定当前的buffer中可以保存多少个void*元素
	//返回值是实际获取的指针个数
	int frames = backtrace(callstack, 128);
	//backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
	//返回一个指向字符串数组的指针
	//每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
	char **strs = backtrace_symbols(callstack, frames);
	
	int i;
	NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	for (i = 0; i < frames; i++) {
		[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	}
	free(strs);
	
	return backtrace;
}

- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {
	//处理报错信息
	//获取运营商
	NSString *carrier = @"";
	//获取设备类型
	NSString *iphoneType = @"";
	
	//获取APP相关信息
	NSString *appInfo = [NSString stringWithFormat:@"App Name : %@ \nApp VersionName : %@ \nApp VersionCode : %@\nDevice Model : %@\nDevice Type : %@\nDevice Carrier : %@\nOS Version : %@ %@\n",
						 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
						 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
						 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
						 [UIDevice currentDevice].model,
						 iphoneType,carrier,
						 [UIDevice currentDevice].systemName,
						 [UIDevice currentDevice].systemVersion];
	//异常信息
	NSString *exceptionInfo = [NSString stringWithFormat:@"\n************* Crash Log Head *************\n%@************* Crash Log Head ****************\n%@exception name      :%@\nexception reason    :%@\nexception userInfo  :%@",appInfo,@"~",exception.name, exception.reason, exception.userInfo ? : @"no user info"];
	
	//奔溃异常信息写入Cache/Analytics文件夹中,并且保持txt，文件名为Crash_Log_时间搓
	NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
	[dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *date = [dateformat stringFromDate:[NSDate date]];
	
	//获取异常
	self.crsField.crash = exceptionInfo;
	
	//访问时间（YYYY-MM-DD HH24:MI:SS必填）
	self.crsField.date = date;
	
	//保存到数据库
}


- (void)handleException:(NSException *)exception {
	//捕获异常信息
	[self validateAndSaveCriticalApplicationData:exception];
}

@end
