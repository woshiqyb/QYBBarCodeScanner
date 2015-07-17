//
//  QYBSquareOverLayer.m
//  QYBBarCodeScanner
//
//  Created by qianyb on 15/7/17.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//

#import "QYBSquareOverLayer.h"

@implementation QYBSquareOverLayer

- (void)drawInContext:(CGContextRef)ctx{
    //设置画笔颜色和宽度
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    CGContextSetLineWidth(ctx, 6);
    CGFloat length = 15;
    //左上角
    CGContextMoveToPoint(ctx, 0, length);
    CGContextAddLineToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, length, 0);
    CGContextStrokePath(ctx);
    
    //右上角
    CGContextMoveToPoint(ctx, CGRectGetWidth(self.bounds) - length, 0);
    CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds), 0);
    CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds), length);
    CGContextStrokePath(ctx);
    
    //左下角
    CGContextMoveToPoint(ctx, 0, CGRectGetHeight(self.bounds) - length);
    CGContextAddLineToPoint(ctx, 0, CGRectGetHeight(self.bounds));
    CGContextAddLineToPoint(ctx, length, CGRectGetHeight(self.bounds));
    CGContextStrokePath(ctx);
    
    //右下角
    CGContextMoveToPoint(ctx, CGRectGetWidth(self.bounds) - length, CGRectGetHeight(self.bounds));
    CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - length);
    CGContextStrokePath(ctx);
}

@end
