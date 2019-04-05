//
//  DBQRCodeScanViewController.h
//  DBQRCode
//
//  Created by bob on 2019/4/4.
//

#import <UIKit/UIKit.h>
#import "DBQRCodeScanner.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBQRCodeScanViewController : UIViewController

/**
 Creates a new instance of `DBQRCodeScanViewController` with callback.
 */
- (instancetype)initWithCallback:(DBQRCodeScanCallback)callback NS_DESIGNATED_INITIALIZER;

/**
 @warning Only the designated initializer should be used to create
 an instance of `DBQRCodeScanViewController`.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodeScanViewController`.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodeScanViewController`.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodeScanViewController`.
 */
+ (instancetype)new NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
