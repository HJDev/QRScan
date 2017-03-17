//
//  HJOtherViewController.m
//  QRScan
//
//  Created by HeJun<mail@hejun.org> on 17/03/2017.
//  Copyright © 2017 HeJun. All rights reserved.
//

#import "HJOtherViewController.h"
#import <Masonry.h>

@interface HJOtherViewController ()

@property (nonatomic, strong) UILabel *scanResultLabel;

@end

@implementation HJOtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSStringFromClass(self.class);
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self.view addSubview:self.scanResultLabel];
	self.scanResultLabel.text = self.scanResult;
	
	[self.view setNeedsUpdateConstraints];
	[self.view updateConstraintsIfNeeded];
	[self.view layoutIfNeeded];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	
	__weak typeof(self)weakSelf = self;
	[self.scanResultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.mas_equalTo(weakSelf.view);
	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazyload
- (UILabel *)scanResultLabel {
	if (_scanResultLabel == nil) {
		_scanResultLabel = [UILabel new];
		_scanResultLabel.numberOfLines = 0;
		_scanResultLabel.textAlignment = NSTextAlignmentCenter;
	}
	return _scanResultLabel;
}

@end
