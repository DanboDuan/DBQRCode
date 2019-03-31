//
//  DBImageHelper.h
//  DBQRCode
//
//  Created by bob on 2019/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBImageHelper : NSObject

+ (UIImage *)scaleImage:(CIImage *)image toSize:(CGSize)size;

+ (UIImage *)combinateCodeImage:(UIImage *)codeImage andLogo:(UIImage *)logo;

+ (void)switchTorch:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
