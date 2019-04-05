//
//  DBDeviceHelper.m
//  DBQRCode
//
//  Created by bob on 2019/4/3.
//

#import "DBDeviceHelper.h"
#import <AVFoundation/AVFoundation.h>

@implementation DBDeviceHelper

+ (void)switchTorch:(BOOL)on {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureTorchMode torchMode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;

    if (device.hasFlash && device.hasTorch && torchMode != device.torchMode) {
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    }
}

@end
