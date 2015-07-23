//
//  ViewController.m
//  QYBBarCodeScanner
//
//  Created by qianyb on 15/7/17.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//
//  参考：http://blog.cnbluebox.com/blog/2014/08/26/ioser-wei-ma-sao-miao/
//

#import "ViewController.h"
#import "QYBBarCodeScannerVC.h"

@interface ViewController ()<QYBBarCodeScannerVCDelegate>

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startBarCodeScanner:(id)sender {
    QYBBarCodeScannerVC *scannerVC = [[QYBBarCodeScannerVC alloc] init];
    scannerVC.delegate = self;
    [self presentViewController:scannerVC animated:YES completion:nil];
}

#pragma mark - QYBBarCodeScannerVCDelegate
- (void)didCaptureInfoInBarCode:(NSString *)info{
    _resultLabel.text = info;
    
}
@end
