//
//  HJQRScanViewController.m
//  QRScan
//
//  Created by HeJun<mail@hejun.org> on 16/03/2017.
//  Copyright © 2017 HeJun. All rights reserved.
//

#import "HJQRScanViewController.h"
#import <Masonry.h>

#ifndef RGBA
#define RGBA(r,g,b,a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:a]
#endif

#ifndef RGB
#define RGB(r,g,b) RGBA(r,g,b,1.0)
#endif

#define HJWeakSelf __weak typeof(self) weakSelf = self
#define HJStrongSelf __strong typeof(self) strongSelf = weakSelf
/** 扫描区域宽度、高度 */
#define ScanViewWidth 200
/** 扫描边角宽度 */
#define ScanAngelWidth 0

/** 定义图片地址 */
#define HJScanSrcFile(file) [@"HJScan.bundle" stringByAppendingPathComponent:file]

@interface HJQRScanViewController ()

/** 顶部填充区 */
@property (nonatomic, strong) UIView *topBlank;
/** 底部填充区 */
@property (nonatomic, strong) UIView *bottomBlank;
/** 左边填充区 */
@property (nonatomic, strong) UIView *leftBlank;
/** 右边填充区 */
@property (nonatomic, strong) UIView *rightBlank;

/** 左上角边框 */
@property (nonatomic, strong) UIImageView *leftTopAngle;
/** 右上角边框 */
@property (nonatomic, strong) UIImageView *rightTopAngle;
/** 左下角边框 */
@property (nonatomic, strong) UIImageView *leftBottomAngle;
/** 右下角边框 */
@property (nonatomic, strong) UIImageView *rightBottomAngle;
/** 扫描线条 */
@property (nonatomic, strong) UIImageView *scanLine;

@end

@implementation HJQRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	[self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	NSLog(@"%s", __func__);
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	
	[self setupViewConstraints];
}

/**
 * 初始化控件
 */
- (void)setupViews {
	[self.view addSubview:self.topBlank];
	[self.view addSubview:self.bottomBlank];
	[self.view addSubview:self.leftBlank];
	[self.view addSubview:self.rightBlank];
	
	[self.view addSubview:self.leftTopAngle];
	[self.view addSubview:self.rightTopAngle];
	[self.view addSubview:self.leftBottomAngle];
	[self.view addSubview:self.rightBottomAngle];
	[self.view addSubview:self.scanLine];
	
	[self.view setNeedsUpdateConstraints];
	[self.view updateConstraintsIfNeeded];
	[self.view layoutIfNeeded];
	
	[self scanLineAnimation];
	
}

/**
 * 添加控件约束
 */
- (void)setupViewConstraints {
	HJWeakSelf;
	//blank view constraints
	[self.topBlank mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.left.right.mas_equalTo(weakSelf.view);
		make.height.mas_equalTo(200);
	}];
	
	[self.bottomBlank mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.left.right.mas_equalTo(weakSelf.view);
		make.top.mas_equalTo(weakSelf.topBlank.mas_bottom).offset(ScanViewWidth);
	}];
	
	[self.leftBlank mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(weakSelf.view);
		make.top.mas_equalTo(weakSelf.topBlank.mas_bottom);
		make.bottom.mas_equalTo(weakSelf.bottomBlank.mas_top);
	}];
	
	[self.rightBlank mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(weakSelf.leftBlank.mas_right).offset(ScanViewWidth);
		make.right.mas_equalTo(weakSelf.view);
		make.top.mas_equalTo(weakSelf.topBlank.mas_bottom);
		make.bottom.mas_equalTo(weakSelf.bottomBlank.mas_top);
		make.width.mas_equalTo(weakSelf.leftBlank);
	}];
	
	//scan angle constraints
	[self.leftTopAngle mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(weakSelf.leftBlank.mas_right).offset(-ScanAngelWidth);
		make.top.mas_equalTo(weakSelf.topBlank.mas_bottom).offset(-ScanAngelWidth);
		make.size.mas_equalTo(weakSelf.leftTopAngle.image.size);
	}];
	
	[self.rightTopAngle mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.mas_equalTo(weakSelf.rightBlank.mas_left).offset(ScanAngelWidth);
		make.top.mas_equalTo(weakSelf.topBlank.mas_bottom).offset(-ScanAngelWidth);
		make.size.mas_equalTo(weakSelf.rightTopAngle.image.size);
	}];
	
	[self.leftBottomAngle mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(weakSelf.leftBlank.mas_right).offset(-ScanAngelWidth);
		make.bottom.mas_equalTo(weakSelf.bottomBlank.mas_top).offset(ScanAngelWidth);
		make.size.mas_equalTo(weakSelf.leftBottomAngle.image.size);
	}];
	
	[self.rightBottomAngle mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.mas_equalTo(weakSelf.rightBlank.mas_left).offset(ScanAngelWidth);
		make.bottom.mas_equalTo(weakSelf.bottomBlank.mas_top).offset(ScanAngelWidth);
		make.size.mas_equalTo(weakSelf.rightBottomAngle.image.size);
	}];
	
	[self.scanLine mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.mas_equalTo(weakSelf.leftBlank.mas_right);
		make.right.mas_equalTo(weakSelf.rightBlank.mas_left);
		make.height.mas_equalTo(weakSelf.scanLine.image.size.height);
		make.top.mas_equalTo(weakSelf.topBlank.mas_bottom);
	}];
}

/**
 * 扫描线条动画
 */
- (void)scanLineAnimation {
	HJWeakSelf;
	[UIView animateWithDuration:2.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		[weakSelf.scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo(weakSelf.topBlank.mas_bottom).offset(ScanViewWidth);
		}];
		[weakSelf.scanLine setNeedsUpdateConstraints];
		[weakSelf.scanLine updateConstraintsIfNeeded];
		[weakSelf.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		[weakSelf.scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo(weakSelf.topBlank.mas_bottom);
		}];
		[weakSelf.scanLine setNeedsUpdateConstraints];
		[weakSelf.scanLine updateConstraintsIfNeeded];
		[weakSelf.view layoutIfNeeded];
		
		[weakSelf scanLineAnimation];
	}];
}

#pragma mark - lazyload
- (UIView *)topBlank {
	if (_topBlank == nil) {
		_topBlank = [UIView new];
		_topBlank.backgroundColor = RGBA(0, 0, 0, 0.3);
	}
	return _topBlank;
}

- (UIView *)bottomBlank {
	if (_bottomBlank == nil) {
		_bottomBlank = [UIView new];
		_bottomBlank.backgroundColor = RGBA(0, 0, 0, 0.3);
	}
	return _bottomBlank;
}

- (UIView *)leftBlank {
	if (_leftBlank == nil) {
		_leftBlank = [UIView new];
		_leftBlank.backgroundColor = RGBA(0, 0, 0, 0.3);
	}
	return _leftBlank;
}

- (UIView *)rightBlank {
	if (_rightBlank == nil) {
		_rightBlank = [UIView new];
		_rightBlank.backgroundColor = RGBA(0, 0, 0, 0.3);
	}
	return _rightBlank;
}

- (UIImageView *)leftTopAngle {
	if (_leftTopAngle == nil) {
		_leftTopAngle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:HJScanSrcFile(@"leftTopAngle")]];
	}
	return _leftTopAngle;
}

- (UIImageView *)rightTopAngle {
	if (_rightTopAngle == nil) {
		_rightTopAngle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:HJScanSrcFile(@"rightTopAngle")]];
	}
	return _rightTopAngle;
}

- (UIImageView *)leftBottomAngle {
	if (_leftBottomAngle == nil) {
		_leftBottomAngle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:HJScanSrcFile(@"leftBottomAngle")]];
	}
	return _leftBottomAngle;
}

- (UIImageView *)rightBottomAngle {
	if (_rightBottomAngle == nil) {
		_rightBottomAngle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:HJScanSrcFile(@"rightBottomAngle")]];
	}
	return _rightBottomAngle;
}

- (UIImageView *)scanLine {
	if (_scanLine == nil) {
		_scanLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:HJScanSrcFile(@"scanLine")]];
	}
	return _scanLine;
}

@end
