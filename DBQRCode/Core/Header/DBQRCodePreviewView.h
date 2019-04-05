//
//  DBQRCodePreviewView.h
//  DBQRCode
//
//  Created by bob on 2019/4/2.
//

#import <UIKit/UIKit.h>
#import "DBQRCodePreview.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBQRCodePreviewView : UIView <DBQRCodePreview>

/**
 The property from DBQRCodePreview.
 */
@property (nonatomic, assign, readonly) CGRect rectFrame;
@property (nonatomic, strong, readonly) UIColor *rectColor;
@property (nonatomic, weak) id<DBQRCodePreviewDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *previewView;

/**
 Creates a new instance of `DBQRCodePreviewView` with frame and the default rectColor and rectFrame.
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 Creates a new instance of `DBQRCodePreviewView` with frame and rectColor and the default rectFrame.
 */
- (instancetype)initWithFrame:(CGRect)frame rectColor:(UIColor *)rectColor;

/**
 Creates a new instance of `DBQRCodePreviewView` with frame and rectColor and the rectFrame.
 */
- (instancetype)initWithFrame:(CGRect)frame rectColor:(UIColor *)rectColor rectFrame:(CGRect)rectFrame NS_DESIGNATED_INITIALIZER;

/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodePreviewView`.
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodePreviewView`.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 @warning Only the designated initializer should be used to create an instance of `DBQRCodePreviewView`.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
