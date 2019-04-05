//
//  DBQRCodeScanner.h
//  DBQRCode
//
//  Created by bob on 2019/4/4.
//

#import <UIKit/UIKit.h>

@protocol DBQRCodePreviewDelegate;
@protocol DBQRCodePreview;

typedef void (^DBQRCodeScanCallback)(NSString * _Nullable code, NSError * _Nullable error);
UIKIT_EXTERN NSInteger const DBQRErrorCodePHAuthorizationStatusNotAllow;
UIKIT_EXTERN NSInteger const DBQRErrorCodeAVAuthorizationStatusNotAllow;

NS_ASSUME_NONNULL_BEGIN

@interface DBQRCodeScanner : NSObject

/**
 Creates a new instance of `DBQRCodeScanner` with preview.
 */
- (instancetype)initWithPreview:(id<DBQRCodePreview>)preview NS_DESIGNATED_INITIALIZER;

/**
 using camera scan QRCode with callback.

 @param callback The callback when scan the QRCode.

 */
- (void)scanWithCallback:(DBQRCodeScanCallback)callback;

/**
 stop scan
 */
- (void)stopScan;

/**
 scan QRCode in photo library with callback.

 @param rooter The UIViewController that will present the UIImagePickerController.

 @param callback The callback when scan the QRCode.

 */
- (void)scanAlbumWithRooter:(UIViewController *)rooter callback:(DBQRCodeScanCallback)callback;

/**
 load scanner again after you request permission successfully

 @warning Only call when you get a DBQRErrorCode from callback and then you want to continue scan after handling the error code correctly
 @warning you should recall `scanWithCallback` or `scanAlbumWithRooter:callback` after you loadScanner
 */
- (void)loadScanner;


/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodeScanner`.
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodeScanner`.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
