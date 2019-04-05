//
//  DBQRCodeManager.m
//  DBQRCode
//
//  Created by bob on 2019/3/31.
//

#import "DBQRCodeManager.h"
#import "DBImageHelper.h"
#import "DBDeviceHelper.h"

#import <CoreImage/CoreImage.h>

static NSString * const DBInputCorrectionLevelL = @"L";
static NSString * const DBInputCorrectionLevelM = @"M";
static NSString * const DBInputCorrectionLevelQ = @"Q";
static NSString * const DBInputCorrectionLevelH = @"H";

static NSString * const DBQRCodeGenerator = @"CIQRCodeGenerator";
static NSString * const DBCode128BarcodeGenerator = @"CICode128BarcodeGenerator";

static NSString * const DBInputMessage = @"inputMessage";
static NSString * const DBInputCorrectionLevel = @"inputCorrectionLevel";
static NSString * const DBInputQuietSpace = @"inputQuietSpace";

@implementation DBQRCodeManager

#pragma mark - 生成二维码

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size {
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:DBQRCodeGenerator
                            withInputParameters:@{DBInputMessage: codeData,
                                                  DBInputCorrectionLevel: DBInputCorrectionLevelH}];
    UIImage *codeImage = [DBImageHelper scaleImage:filter.outputImage toSize:size];

    return codeImage;
}

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(UIImage *)logo {
    UIImage *codeImage = [self generateQRCode:code size:size];
    codeImage = [DBImageHelper combinateCodeImage:codeImage andLogo:logo];

    return codeImage;
}

#pragma mark - 条形码
+ (UIImage *)generateBarCode:(NSString *)code size:(CGSize)size {
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:DBCode128BarcodeGenerator
                            withInputParameters:@{DBInputMessage: codeData,
                                                  DBInputQuietSpace: @.0}];
    UIImage *codeImage = [DBImageHelper scaleImage:filter.outputImage toSize:size];

    return codeImage;
}

+ (NSString *)detectQRCode:(UIImage *)image {
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >=1) {
        CIQRCodeFeature *feature = [features firstObject];
        
        return feature.messageString;
    }

    return nil;
}
@end
