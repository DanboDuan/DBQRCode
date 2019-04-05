//
//  DBQRCodeManager.h
//  DBQRCode
//
//  Created by bob on 2019/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBQRCodeManager : NSObject

#pragma mark - 生成二维码

/**
 Return the legend view with row count of plots.

 @param code The string to generate QRCode image.

 @param size The size to generate QRCode image.

 @return UIImage The QRCode image.
 */
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size;

/**
 Return the legend view with row count of plots.

 @param code The string to generate QRCode image.

 @param size The size to generate QRCode image.

 @param logo The logo added to generated QRCode image.

 @return UIImage The QRCode image.
 */
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(UIImage *)logo;

#pragma mark - 条形码

/**
 Return the legend view with row count of plots.

 @param code The string to generate BarCode image.

 @param size The size to generate BarCode image.

 @return UIImage The QRCode image.
 */
+ (UIImage *)generateBarCode:(NSString *)code size:(CGSize)size;

/**
 Return the legend view with row count of plots.

 @param image The QRCode image to detect data.

 @return NSString The detected data string.
 */
+ (nullable NSString *)detectQRCode:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
