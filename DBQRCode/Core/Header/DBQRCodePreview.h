//
//  DBQRCodePreview.h
//  DBQRCode
//
//  Created by bob on 2019/4/2.
//

#import <UIKit/UIKit.h>

@protocol DBQRCodePreviewDelegate;
@protocol DBQRCodePreview;

@protocol DBQRCodePreview <NSObject>

/**
 The Preview rect for scanning area.
 */
@property (nonatomic, assign, readonly) CGRect rectFrame;

/**
 The Preview rect color for scanning area.
 */
@property (nonatomic, strong, readonly) UIColor *rectColor;

/**
 The Preview delegate.
 */
@property (nonatomic, weak) id<DBQRCodePreviewDelegate> delegate;

/**
 The Preview View.
 */
@property (nonatomic, strong, readonly) UIView *previewView;

/**
 this method will be called when start scanning. The Preview should prepare for scanning
 */
- (void)startScanning;

/**
 this method will be called when stop scanning. The Preview should prepare for stop scanning
 */
- (void)stopScanning;

/**
 this method will be called when get result from scanning and start to show result. The Preview should prepare for start indicating
 */
- (void)startIndicating;

/**
 this method will be called when finish indicating. The Preview should prepare for stop indicating
 */
- (void)stopIndicating;

/**
 this method will be called when the light is dark. The Preview should prepare a button to turn on the torch
 */
- (void)showTorchSwitch;

/**
 this method will be called when the light is not dark anymore. The Preview should hide the button to turn on the torch
 */
- (void)hideTorchSwitch;

@end


@protocol DBQRCodePreviewDelegate <NSObject>

/**
 The button to turn on the torch is tapped.

 @param previewView The previewView.

 @param onState The state of the the button to turn on the torch.

 */
- (void)codePreviewView:(id<DBQRCodePreview>)previewView torchSwitchTapped:(BOOL)onState;

@end
