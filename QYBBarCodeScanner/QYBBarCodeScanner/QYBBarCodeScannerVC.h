//
//  QYBBarCodeScannerVC.h
//  QYBBarCodeScanner
//
//  Created by qianyb on 15/7/23.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QYBBarCodeScannerVCDelegate <NSObject>

@required
/**
 *  扫描成功之后会在主线程返回条形码、二维码对应的信息
 */
- (void)didCaptureInfoInBarCode:(NSString *)info;

@end

@interface QYBBarCodeScannerVC : UIViewController

@property (nonatomic, weak) id<QYBBarCodeScannerVCDelegate> delegate;

/**
 *  中间扫描区域。
 *  默认居中，宽高均为手机宽度的一半
 */
@property (nonatomic, assign) CGRect cropRect;
@end
