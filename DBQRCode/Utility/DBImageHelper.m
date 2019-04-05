//
//  DBImageHelper.m
//  DBQRCode
//
//  Created by bob on 2019/3/31.
//

#import "DBImageHelper.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation DBImageHelper

+ (UIImage *)scaleImage:(CIImage *)image toSize:(CGSize)size {

    CGRect integralRect = image.extent;
    CGImageRef imageRef = [[CIContext context] createCGImage:image fromRect:integralRect];

    CGFloat sideScale = fminf(size.width / integralRect.size.width, size.width / integralRect.size.height) * [UIScreen mainScreen].scale;
    size_t contextRefWidth = ceilf(integralRect.size.width * sideScale);
    size_t contextRefHeight = ceilf(integralRect.size.height * sideScale);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, contextRefWidth, contextRefHeight, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpaceRef);

    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, sideScale, sideScale);
    CGContextDrawImage(contextRef, integralRect, imageRef);
    CGImageRelease(imageRef);

    CGImageRef scaledImageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);

    UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(scaledImageRef);

    return scaledImage;
}

+ (UIImage *)combinateCodeImage:(UIImage *)codeImage andLogo:(UIImage *)logo {

    UIGraphicsBeginImageContextWithOptions(codeImage.size, YES, [UIScreen mainScreen].scale);
    [codeImage drawInRect:(CGRect){.0, .0, codeImage.size.width, codeImage.size.height}];
    CGFloat logoSide = fminf(codeImage.size.width, codeImage.size.height) / 4;
    CGFloat logoX = (codeImage.size.width - logoSide) / 2;
    CGFloat logoY = (codeImage.size.height - logoSide) / 2;
    CGRect logoRect = CGRectMake(logoX, logoY, logoSide, logoSide);
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:logoRect cornerRadius:logoSide / 5];
    [cornerPath setLineWidth:2.0];
    [[UIColor whiteColor] set];
    [cornerPath stroke];
    [cornerPath addClip];
    [logo drawInRect:logoRect];
    codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return codeImage;
}


@end
