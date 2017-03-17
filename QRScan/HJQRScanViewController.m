//
//  HJQRScanViewController.m
//  QRScan
//
//  Created by HeJun<mail@hejun.org> on 16/03/2017.
//  Copyright © 2017 HeJun. All rights reserved.
//

#import "HJQRScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HJOtherViewController.h"
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
/** 扫描区域距顶部高度 */
#define ScanViewMarginTop 200
#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height
/** 扫描边角宽度 */
#define ScanAngelWidth 0

/** 定义图片地址 */
#define HJScanSrcFile(file) [@"HJScan.bundle" stringByAppendingPathComponent:file]

@interface HJQRScanViewController ()<AVCaptureMetadataOutputObjectsDelegate> {
	dispatch_queue_t queue;
}

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

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation HJQRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	//初始化控件
	[self setupViews];
	//初始化视频捕捉
	[self setupCapture];
}

- (instancetype)init {
	if (self = [super init]) {
		queue = dispatch_queue_create("org.hejun.QRScan", NULL);
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.captureSession startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	if ([self.captureSession isRunning]) {
		[self.captureSession stopRunning];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	NSLog(@"%s", __func__);
	if ([self.captureSession isRunning]) {
		[self.captureSession stopRunning];
	}
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
		make.height.mas_equalTo(ScanViewMarginTop);
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
	
	[self.scanLine.layer removeAllAnimations];
	[self.scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(weakSelf.topBlank.mas_bottom);
	}];
	[self.scanLine setNeedsUpdateConstraints];
	[self.scanLine updateConstraintsIfNeeded];
	[self.view layoutIfNeeded];
	
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

/**
 * 显示提示
 */
- (void)showAlertTitle:(NSString *)title message:(NSString *)message {
	if (title == nil) {
		title = @"系统提示";
	}
	
	if (message == nil) {
		message = @"";
	}
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:confirmAction];
	[self presentViewController:alert animated:YES completion:nil];
}

/**
 * 初始化Capture
 */
- (void)setupCapture {
	AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[captureDevice lockForConfiguration:nil];
	if ([captureDevice hasTorch]) {
		[captureDevice setTorchMode:AVCaptureTorchModeAuto];
	}
	[captureDevice unlockForConfiguration];
	
	NSError *error = nil;
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
	if (error) {
		NSLog(@"%@", error);
		return;
	}
	
	if (!captureInput) {
		if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
			[self showAlertTitle:@"系统提示" message:@"您已关闭相机使用权限，请至手机“设置->隐私->相机”中打开"];
		} else {
			[self showAlertTitle:@"系统提示" message:@"未能找到相机设备"];
		}
		return;
	}
	
	AVCaptureMetadataOutput *captureOutput = [[AVCaptureMetadataOutput alloc] init];
	[captureOutput setMetadataObjectsDelegate:self queue:queue];
	
	captureOutput.rectOfInterest = [UIScreen mainScreen].bounds;
	
	AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
	self.captureSession = captureSession;
	[captureSession addInput:captureInput];
	[captureSession addOutput:captureOutput];
	
	captureOutput.metadataObjectTypes = captureOutput.availableMetadataObjectTypes;//需要在添加到captureSession后才能获取到值
	
	if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
		if ([captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
			[captureSession setSessionPreset:AVCaptureSessionPreset3840x2160];
		}
	} else {
		if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
			[captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
		} else if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
			[captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
		} else if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
			[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
		} else if ([captureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
			[captureSession setSessionPreset:AVCaptureSessionPreset352x288];
		}
	}
	
	AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
	previewLayer.frame = [UIScreen mainScreen].bounds;
	previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer insertSublayer:previewLayer atIndex:0];
	
	CGRect rect = CGRectMake((Width - ScanViewWidth) * 0.5, ScanViewMarginTop, ScanViewWidth, ScanViewWidth);
	
	captureOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:rect];
	
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
	if (!metadataObjects.count) {
		return;
	}
	for (NSObject *obj in metadataObjects) {
		if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
			
			AVMetadataMachineReadableCodeObject *codeObj = (AVMetadataMachineReadableCodeObject *)obj;
			[self stopScanWithResult:codeObj.stringValue];
			[self playBeep];
			
		}
	}
}


#pragma mark - scan actions
/**
 * 开始扫描
 */
- (void)startScan {
	if (![self.captureSession isRunning]) {
		[self.captureSession startRunning];
	}
}

/**
 * 停止扫描
 */
- (void)stopScanWithResult:(NSString *)result {
	if ([self.captureSession isRunning]) {
		[self.captureSession stopRunning];
		
		HJWeakSelf;
		[self showInMainThread:^{
			HJOtherViewController *otherVc = [HJOtherViewController new];
			otherVc.scanResult = result;
			[weakSelf.navigationController pushViewController:otherVc animated:YES];
		}];
		
	}
}

/**
 * 在主线程操作视图
 */
- (void)showInMainThread:(dispatch_block_t)block {
	if (![[NSThread currentThread] isMainThread]) {
		dispatch_async(dispatch_get_main_queue(), block);
	} else {
		block();
	}
}

/**
 * 播放哔声
 */
- (void)playBeep {
	SystemSoundID sound = kSystemSoundID_Vibrate;
	//alarm.caf
	NSString *path = [NSString stringWithFormat:@"%@%@", @"/System/Library/Audio/UISounds/", @"begin_record.caf"];
	OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([NSURL URLWithString:path]), &sound);
	if (status != kAudioServicesNoError) {
		sound = 0;
	}
	AudioServicesPlaySystemSound(sound);
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
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
