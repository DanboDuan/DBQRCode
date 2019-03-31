//
//  DBQRCodeManager.m
//  DBQRCode
//
//  Created by bob on 2019/3/31.
//

#import "DBQRCodeManager.h"
#import "DBImageHelper.h"

#import <CoreImage/CoreImage.h>

static const NSString *DBInputCorrectionLevelL = @"L";//!< L: 7%
static const NSString *DBInputCorrectionLevelM = @"M";//!< M: 15%
static const NSString *DBInputCorrectionLevelQ = @"Q";//!< Q: 25%
static const NSString *DBInputCorrectionLevelH = @"H";//!< H: 30%

@implementation DBQRCodeManager

#pragma mark - 生成二维码

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size {
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"
                            withInputParameters:@{@"inputMessage": codeData,
                                                  @"inputCorrectionLevel": DBInputCorrectionLevelH}];
    UIImage *codeImage = [DBImageHelper scaleImage:filter.outputImage toSize:size];

    return codeImage;
}

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(UIImage *)logo {
    UIImage *codeImage = [self generateQRCode:code size:size];
    codeImage = [DBImageHelper combinateCodeImage:codeImage andLogo:logo];

    return codeImage;
}

#pragma mark - 条形码
+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size {
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"
                            withInputParameters:@{@"inputMessage": codeData,
                                                  @"inputQuietSpace": @.0}];
    UIImage *codeImage = [DBImageHelper scaleImage:filter.outputImage toSize:size];

    return codeImage;
}

@end
