//
//  QYBBarCodeScannerVC.m
//  QYBBarCodeScanner
//
//  Created by qianyb on 15/7/23.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//

#import "QYBBarCodeScannerVC.h"
#import "QYBSquareOverLayer.h"
#import <AVFoundation/AVFoundation.h>

#ifndef Screen_Width
#define Screen_Width    CGRectGetWidth([[UIScreen mainScreen] bounds])
#endif

#ifndef Screen_Height
#define Screen_Height   CGRectGetHeight([[UIScreen mainScreen] bounds])
#endif

#define Preview_Rect    (self.view.layer.bounds)

#define Crop_Rect       CGRectMake(CGRectGetWidth(Preview_Rect)/4, CGRectGetHeight(Preview_Rect)/4, CGRectGetWidth(Preview_Rect)/2, CGRectGetWidth(Preview_Rect)/2)

@interface QYBBarCodeScannerVC ()<AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation QYBBarCodeScannerVC{
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer;
    
    AVCaptureSession *captureSession;
    
    AVCaptureDevice *captureDevice;
    
    CALayer *scannerLine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (CGRectGetHeight(_cropRect) == 0) {
        _cropRect = Crop_Rect;
    }
    
    [self initAndRunBarCodeScanner];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self addAnimationToScannerLine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initAndRunBarCodeScanner{
    if (!captureSession) {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *lockError;
        if ([captureDevice lockForConfiguration:&lockError]) {
            captureDevice.flashMode = AVCaptureFlashModeAuto;
        }else{
            NSLog(@"未能锁定对设备硬件的控制");
        }
        
        //输入
        NSError *inputError;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&inputError];
        
        if (!input) {
            NSLog(@"\n+++++++\nDevice input error = %@\n+++++++\n",inputError);
            return;
        }
        
        //输出
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        //创建一个同步队列，不去占用主线程
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("QYBQueue", NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        
        //设置只扫描某个固定的区域
        captureMetadataOutput.rectOfInterest = [self transformRect:_cropRect toRectOfInterestWithVideoLayerRect:Preview_Rect];
        
        //配置captureSession
        captureSession = [[AVCaptureSession alloc] init];
        
        if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            //高清的图片解析准确率高，小条形码也可以很好的解析出来
            captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        }else{
            NSLog(@"sessionPreset 不支持1920*1080");
            return;
        }
        
        if ([captureSession canAddInput:input]) {
            [captureSession addInput:input];
        }else{
            NSLog(@"captureSession的输入源添加失败");
            return;
        }
        
        if ([captureSession canAddOutput:captureMetadataOutput]) {
            [captureSession addOutput:captureMetadataOutput];
        }else{
            NSLog(@"captureSession的输出源添加失败");
            return;
        }
        
        //设置识别的类型，二维码的话只需要AVMetadataObjectTypeQRCode
        //类型的设置必须要在被绑定到captureSession之后
        NSArray *availableTypes = [captureMetadataOutput availableMetadataObjectTypes];
        NSMutableSet *codeTypes = [NSMutableSet setWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil];
        [codeTypes intersectSet:[NSMutableSet setWithArray:availableTypes]];
        NSLog(@"availableType = %@,将要被设置的codeType = %@",availableTypes,codeTypes);
        [captureMetadataOutput setMetadataObjectTypes:[codeTypes allObjects]];
    }
    
    if (!videoPreviewLayer) {
        //配置videoPreviewLayer
        videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
        //设置video充满layer
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        videoPreviewLayer.frame = Preview_Rect;
        
        //配置自定义的OverLayer
        [self addForcusLayerToPreviewLayer];
    }
    [self.view.layer insertSublayer:videoPreviewLayer atIndex:0];
    
    [captureSession startRunning];
}

#pragma mark - Private Method
- (void)addForcusLayerToPreviewLayer{
    //中间的扫描框
    QYBSquareOverLayer *squareOverLayer = [[QYBSquareOverLayer alloc] init];
    squareOverLayer.frame = _cropRect;
    squareOverLayer.borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] CGColor];
    squareOverLayer.borderWidth = 2;
    [squareOverLayer display];
    
    //添加扫描框中间的扫描线
    scannerLine = [[CALayer alloc] init];
    scannerLine.frame = CGRectMake(0, 4, CGRectGetWidth(squareOverLayer.bounds), 4);
    scannerLine.contents = (__bridge id)[[UIImage imageNamed:@"line"] CGImage];
    [squareOverLayer addSublayer:scannerLine];
    [videoPreviewLayer addSublayer:squareOverLayer];
    
    //左边的覆盖物
    CALayer *leftOverLayer = [[CALayer alloc] init];
    leftOverLayer.frame = CGRectMake(0, 0, CGRectGetMinX(squareOverLayer.frame), CGRectGetHeight(videoPreviewLayer.bounds));
    [videoPreviewLayer addSublayer:leftOverLayer];
    
    //右边的覆盖物
    CALayer *rightOverLayer = [[CALayer alloc] init];
    rightOverLayer.frame = CGRectMake(CGRectGetMaxX(squareOverLayer.frame), 0, CGRectGetWidth(videoPreviewLayer.bounds) - CGRectGetMaxX(squareOverLayer.frame), CGRectGetHeight(videoPreviewLayer.bounds));
    [videoPreviewLayer addSublayer:rightOverLayer];
    
    //上面的覆盖物
    CALayer *topOverLayer = [[CALayer alloc] init];
    topOverLayer.frame = CGRectMake(CGRectGetMaxX(leftOverLayer.frame), 0, CGRectGetMinX(rightOverLayer.frame) - CGRectGetMaxX(leftOverLayer.frame), CGRectGetMinY(squareOverLayer.frame));
    [videoPreviewLayer addSublayer:topOverLayer];
    
    //下面的覆盖物
    CALayer *bottomOverLayer = [[CALayer alloc] init];
    bottomOverLayer.frame = CGRectMake(CGRectGetMinX(topOverLayer.frame), CGRectGetMaxY(squareOverLayer.frame), CGRectGetWidth(topOverLayer.frame), CGRectGetHeight(videoPreviewLayer.bounds) - CGRectGetMaxY(squareOverLayer.frame));
    [videoPreviewLayer addSublayer:bottomOverLayer];
    
    leftOverLayer.backgroundColor = rightOverLayer.backgroundColor = topOverLayer.backgroundColor = bottomOverLayer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] CGColor];
}

- (void)addAnimationToScannerLine{
    //给中间的扫描框添加扫描动画
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    basicAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(scannerLine.position.x, CGRectGetHeight(_cropRect) - 6)];
    basicAnimation.duration = 2.0;
    basicAnimation.autoreverses = YES;
    //设置重复次数,HUGE_VALF可看做无穷大，起到循环动画的效果
    basicAnimation.repeatCount = HUGE_VALF;
    [scannerLine addAnimation:basicAnimation forKey:@"kBasicAnimation_Transition"];
}

- (CGRect)transformRect:(CGRect)rect toRectOfInterestWithVideoLayerRect:(CGRect)videoRect{
    CGSize size = videoRect.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //因为前面使用了1920*1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = videoRect.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        return CGRectMake((rect.origin.y + fixPadding)/fixHeight,
                          rect.origin.x/size.width,
                          rect.size.height/fixHeight,
                          rect.size.width/size.width);
    } else {
        CGFloat fixWidth = videoRect.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        return CGRectMake(rect.origin.y/size.height,
                          (rect.origin.x + fixPadding)/fixWidth,
                          rect.size.height/size.height,
                          rect.size.width/fixWidth);
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        
        //切回主线程更新视图,停止扫描并释放对设备硬件的控制锁定
        dispatch_async(dispatch_get_main_queue(), ^{
            [captureSession stopRunning];
            [videoPreviewLayer removeFromSuperlayer];
            [captureDevice unlockForConfiguration];
            
            if ([self.delegate respondsToSelector:@selector(didCaptureInfoInBarCode:)]) {
                [self.delegate didCaptureInfoInBarCode:metadataObj.stringValue];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}
@end
