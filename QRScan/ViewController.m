//
//  ViewController.m
//  QRScan
//
//  Created by HeJun<mail@hejun.org> on 16/03/2017.
//  Copyright © 2017 HeJun. All rights reserved.
//

#import "ViewController.h"
#import "HJQRScanViewController.h"

@interface ViewController ()

/** 扫描二位码 */
- (IBAction)scanQRCode:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (IBAction)scanQRCode:(id)sender {
	
	HJQRScanViewController *qrScanVc = [HJQRScanViewController new];
	qrScanVc.title = @"扫一扫";
	
	[self.navigationController pushViewController:qrScanVc animated:YES];
}
@end
