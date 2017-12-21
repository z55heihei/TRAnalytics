//
//  TRAnalyticsAssem.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TRAnalytics.h"
#import "TRAnalyticsAssem.h"
#import "UIControl+TRAnalytics.h"

NSString *const PVTypeMapping[] = {
	[kPVTypeVenderApp] = @"1",
	[kPVTypeAd] = @"2",
	[KPVTypePromotion] = @"3",
	[kPVTypeGrid] = @"4",
	[kPVTypeMessage] = @"5",
	[kPVTypeShare] = @"6",
	[kPVTypeBill] = @"A1",
	[kPVTypeClose] = @"A7",
	[kPVTypeBack] = @"A8",
	[kPVTypeElse] = @"A9",
};

NSString *const PVPlatTypeMapping[] = {
	[kPVPlatTypeIOS] = @"2",
	[kPVPlatTypeWEB] = @"3",
	[kPVPlatTypeWAP] = @"4"
};

@implementation TRAnalyticsAssemPVMaker

- (AssemPVMakerValueBlock)xproductId{
	return ^TRAnalyticsAssemPVMaker *(NSString *value){
		self.productId = value;
		return self;
	};
}

- (AssemPVMakerValueBlock)xtitle{
	return ^TRAnalyticsAssemPVMaker *(NSString *value){
		self.title = value;
		return self;
	};
}

- (AssemPVMakerValueBlock)xpageURL{
	return ^TRAnalyticsAssemPVMaker *(NSString *value){
		self.pageURL = value;
		return self;
	};
}

- (AssemPVMakerTypeBlock)xType{
	return ^TRAnalyticsAssemPVMaker*(PVType type){
		self.type = type;
		return self;
	};
}

+ (TRAnalyticsAssemPVMaker *)makeAssemPV:(void (^)(TRAnalyticsAssemPVMaker *maker))block{
	TRAnalyticsAssemPVMaker *pvMaker = [[TRAnalyticsAssemPVMaker alloc] init];
	block(pvMaker);
	return pvMaker;
}

@end


@implementation TRAnalyticsAssem
+ (void)AssemCLT{
	[TRAnalytics event:nil method:CLT attributes:nil];
}

+ (void)AssemPVMaker:(TRAnalyticsAssemPVMaker *)maker{
	[self AssemPVType:maker.type maker:maker];
}

+ (void)AssemPVType:(PVType)type maker:(TRAnalyticsAssemPVMaker *)maker{
	NSString *productId = maker.productId;
	NSDictionary *attributes = [self pvAttributesType:type maker:maker];
	
	[TRAnalytics event:productId 
				method:PV 		  
			attributes:attributes];
}

+ (void)AssemPVType:(PVType)type maker:(TRAnalyticsAssemPVMaker *)maker control:(UIControl *)control{	
	NSString *productId = maker.productId;	
	NSDictionary *attributes = [self pvAttributesType:type maker:maker];
	
	[control event:productId 
			method:PV 		  
		attributes:attributes];
}

+ (NSDictionary *)pvAttributesType:(PVType)type 
							 maker:(TRAnalyticsAssemPVMaker *)maker{
	NSString *xtitle = maker.title;
	NSString *xpageURL = maker.pageURL;
	NSString *pageType = PVTypeMapping[type];
	NSString *platform = PVPlatTypeMapping[kPVPlatTypeIOS];
	
	NSDictionary *attributes = @{@"pageURL":xpageURL,
								 @"pageType":pageType,
								 @"pageName":xtitle,
								 @"platform":platform};
	return attributes;
} 
@end
