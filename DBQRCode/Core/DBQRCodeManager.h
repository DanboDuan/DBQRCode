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

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size;

+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size logo:(UIImage *)logo;

#pragma mark - 条形码

+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
