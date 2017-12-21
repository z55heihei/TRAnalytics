//
//  ViewController.m
//  TRAnalytics
//
//  Created by ZYW on 2017/7/5.
//  Copyright © 2017年 ZYW. All rights reserved.
//

#import "ViewController.h"
#import "TRAnalyticsAssem.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	/*
	[TRAnalyticsAssem AssemPVMaker:[TRAnalyticsAssemPVMaker makeAssemPV:^(TRAnalyticsAssemPVMaker *maker) {
		maker.xtitle(@"测试").xpageURL(NSStringFromClass([ViewController class]))
	}] ];
	*/
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
