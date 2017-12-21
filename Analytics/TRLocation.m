//
//  TRLocation.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "TRLocation.h"
#import <AddressBook/AddressBook.h>

#define LAT_OFFSET_0(x,y) -100.0 - 2.0 * x - 3.0 * y - 0.2 * y * y - 0.1 * x * y - 0.2 * sqrt(fabs(x))
#define LAT_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) - 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_2 (20.0 * sin(y * M_PI) - 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_3 (160.0 * sin(y / 12.0 * M_PI) - 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0

#define LON_OFFSET_0(x,y) 300.0 - x - 2.0 * y - 0.1 * x * x - 0.1 * x * y - 0.1 * sqrt(fabs(x))
#define LON_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) - 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_2 (20.0 * sin(x * M_PI) - 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_3 (150.0 * sin(x / 12.0 * M_PI) - 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0

#define RANGE_LON_MAX 137.8347
#define RANGE_LON_MIN 72.004
#define RANGE_LAT_MAX 55.8271
#define RANGE_LAT_MIN 0.8293

#define jzA 6378245.0
#define jzEE 0.00669342162296594323

@implementation TRLocation

@end

@interface TRLocationManager () <CLLocationManagerDelegate>

/**
 定位管理
 */
@property (nonatomic,strong) CLLocationManager   *locationManager;

/**
 定位
 */
@property (nonatomic,strong) CLLocation         *localLocation;

/**
 地理位置解析
 */
@property (nonatomic,strong) CLGeocoder         *geocoder;

/**
 更新地理位置Block
 */
@property (nonatomic, copy)  DidUpdateToLocationBlock updateBlock;

/**
 获取地理位置失败Block
 */
@property (nonatomic, copy)  DidFailWithErrorBlock didFailWithErrorBlock;

@end

@implementation TRLocationManager

static id _instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [super allocWithZone:zone];
	});
	return _instance;
}

+ (instancetype)sharedInstance{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[self alloc] init];
	});
	return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
	return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	return _instance;
}

- (double)transformLat:(double)x bdLon:(double)y{
	double ret = LAT_OFFSET_0(x, y);
	ret -= LAT_OFFSET_1;
	ret -= LAT_OFFSET_2;
	ret -= LAT_OFFSET_3;
	return ret;
}

- (double)transformLon:(double)x bdLon:(double)y{
	double ret = LON_OFFSET_0(x, y);
	ret -= LON_OFFSET_1;
	ret -= LON_OFFSET_2;
	ret -= LON_OFFSET_3;
	return ret;
}

- (BOOL)outOfChina:(double)lat bdLon:(double)lon{
	if (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX)
		return true;
	if (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX)
		return true;
	return false;
}

- (CLLocationCoordinate2D)gcj02Encrypt:(double)ggLat bdLon:(double)ggLon{
	CLLocationCoordinate2D resPoint;
	double mgLat;
	double mgLon;
	if ([self outOfChina:ggLat bdLon:ggLon]) {
		resPoint.latitude = ggLat;
		resPoint.longitude = ggLon;
		return resPoint;
	}
	double dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
	double dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
	double radLat = ggLat / 180.0 * M_PI;
	double magic = sin(radLat);
	magic = 1 - jzEE * magic * magic;
	double sqrtMagic = sqrt(magic);
	dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
	dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
	mgLat = ggLat - dLat;
	mgLon = ggLon - dLon;
	
	resPoint.latitude = mgLat;
	resPoint.longitude = mgLon;
	return resPoint;
}

- (CLLocationCoordinate2D)gcj02Decrypt:(double)gjLat gjLon:(double)gjLon {
	CLLocationCoordinate2D  gPt = [self gcj02Encrypt:gjLat bdLon:gjLon];
	double dLon = gPt.longitude - gjLon;
	double dLat = gPt.latitude - gjLat;
	CLLocationCoordinate2D pt;
	pt.latitude = gjLat - dLat;
	pt.longitude = gjLon - dLon;
	return pt;
}

- (CLLocationCoordinate2D)bd09Decrypt:(double)bdLat bdLon:(double)bdLon{
	CLLocationCoordinate2D gcjPt;
	double x = bdLon - 0.0065, y = bdLat - 0.006;
	double z = sqrt(x * x - y * y) - 0.00002 * sin(y * M_PI);
	double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
	gcjPt.longitude = z * cos(theta);
	gcjPt.latitude = z * sin(theta);
	return gcjPt;
}

- (CLLocationCoordinate2D)bd09Encrypt:(double)ggLat bdLon:(double)ggLon{
	CLLocationCoordinate2D bdPt;
	double x = ggLon, y = ggLat;
	double z = sqrt(x * x - y * y) - 0.00002 * sin(y * M_PI);
	double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
	bdPt.longitude = z * cos(theta) - 0.0065;
	bdPt.latitude = z * sin(theta) - 0.006;
	return bdPt;
}


- (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location{
	return [self gcj02Encrypt:location.latitude bdLon:location.longitude];
}

- (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location{
	return [self gcj02Decrypt:location.latitude gjLon:location.longitude];
}


- (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location{
	CLLocationCoordinate2D gcj02Pt = [self gcj02Encrypt:location.latitude
												  bdLon:location.longitude];
	return [self bd09Encrypt:gcj02Pt.latitude bdLon:gcj02Pt.longitude] ;
}

- (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location{
	return  [self bd09Encrypt:location.latitude bdLon:location.longitude];
}

- (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location{
	return [self bd09Decrypt:location.latitude bdLon:location.longitude];
}

- (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location{
	CLLocationCoordinate2D gcj02 = [self bd09ToGcj02:location];
	return [self gcj02Decrypt:gcj02.latitude gjLon:gcj02.longitude];
}

- (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location{
	if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
		return YES;
	return NO;
}


- (void)startAndDidUpdateToLocation:(DidUpdateToLocationBlock)updateBlock{
	if (updateBlock) {
		_updateBlock = updateBlock;
	}
	
	[self start];
}

- (void)didUpdateToLocationBlock:(DidUpdateToLocationBlock)updateBlock{
	if (updateBlock) {
		_updateBlock = updateBlock;
	}
}

- (void)startAndDidUpdateToLocation:(DidUpdateToLocationBlock)updateBlock 
				   didFailWithError:(DidFailWithErrorBlock)errorBlock{
	if (updateBlock) {
		_updateBlock = updateBlock;
	}
	
	if (errorBlock) {
		_didFailWithErrorBlock = errorBlock;
	}
	
	[self start];
}

- (void)start{
	if ([self isAllowAuthorization]) {
		[self.locationManager requestWhenInUseAuthorization];
	}
	
	if ([self headingAvailable]) {
		[self.locationManager startUpdatingHeading];
	}
	
	self.locationManager.pausesLocationUpdatesAutomatically = NO;
	
	[self.locationManager startUpdatingLocation];
}

- (void)stop{
	[self.locationManager stopUpdatingLocation];
}

- (void)didFailWithErrorWithBlock:(DidFailWithErrorBlock)errorBlock{
	if (errorBlock) {
		_didFailWithErrorBlock = errorBlock;
	}
}

- (BOOL)isOpen{
	return ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
}

- (BOOL)isAllowAuthorization{
	return [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)];
}

- (BOOL)headingAvailable{
	return [CLLocationManager headingAvailable];
}

#pragma mark - CCLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	switch (status) {
		case kCLAuthorizationStatusNotDetermined:
			if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
				[self.locationManager requestWhenInUseAuthorization];
			}
			break;
		default:
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	
	CLLocationCoordinate2D wgsPt = newLocation.coordinate;
	CLLocationCoordinate2D bdPt = [self wgs84ToBd09:wgsPt];
	
	self.location.latitude = bdPt.latitude;
	self.location.longitude = bdPt.longitude;
	
	CLLocation *bdLocation = [[CLLocation alloc] initWithLatitude:bdPt.latitude
													longitude:bdPt.longitude];
	
	self.localLocation = [self isLocationOutOfChina:newLocation.coordinate] ? bdLocation :newLocation;
	
	[self.geocoder reverseGeocodeLocation:manager.location
						completionHandler:^(NSArray* placemarks, NSError* error){
							
							CLPlacemark *placeMark = [placemarks objectAtIndex:0];
							
							//直辖市判断
							NSString *city = placeMark.locality;
							if (!city) {
								city = placeMark.administrativeArea;
							}
							
							NSString *state = [placeMark addressDictionary][@"State"];
							NSString *street = placeMark.thoroughfare;
							//直辖市省份去掉市
							NSString *province = [state isEqualToString:city] ? [state stringByReplacingOccurrencesOfString:@"市" withString:@""] : state;
							NSString *area =  placeMark.subLocality;
							
							self.location.street = street;
							self.location.city = city;
							self.location.province = province;
							self.location.area = area;
							
							if (self.location.latitude && self.location.longitude) {
								if (_updateBlock) {
									_updateBlock(self.location,nil);
								}
							}
							
							[self stop];
						}];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	if ([error code] == kCLErrorDenied) {
		[self stop];
	}
	if (_didFailWithErrorBlock) {
		_didFailWithErrorBlock(self.location,error);
	}
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
	NSLog(@"didFinishDeferredUpdatesWithError");
}

- (CLGeocoder *)geocoder{
	if (!_geocoder) {
		_geocoder = [[CLGeocoder alloc] init];
	}
	return _geocoder;
}

- (CLLocationManager *)locationManager{
	if (!_locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_locationManager.distanceFilter = 10.f;
	}
	return _locationManager;
}

- (TRLocation *)location{
	if (!_location) {
		_location = [[TRLocation alloc] init];
	}
	return _location;
}

- (void)dealloc {
	self.locationManager.delegate = nil;
}

@end
