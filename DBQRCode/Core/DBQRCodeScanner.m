//
//  DBQRCodeScanner.m
//  DBQRCode
//
//  Created by bob on 2019/4/4.
//

#import "DBQRCodeScanner.h"
#import "DBQRCodePreview.h"
#import "DBDeviceHelper.h"
#import "DBQRCodeManager.h"

#import <AVFoundation/AVFoundation.h>


#define DBQRCodeWeakSelf __weak typeof(self) wself = self
#define DBQRCodeStrongSelf __strong typeof(wself) self = wself


NSInteger const DBQRErrorCodePHAuthorizationStatusNotAllow = 101;
NSInteger const DBQRErrorCodeAVAuthorizationStatusNotAllow = 102;

@interface DBQRCodeScanner () <DBQRCodePreviewDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) DBQRCodeScanCallback callback;
@property (nonatomic, copy) void(^lightObserver)(BOOL dimmed, BOOL torchOn);
@property (nonatomic, assign) BOOL lightObserverCalled;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) id<DBQRCodePreview> preview;

@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, assign) BOOL torchOn;

@property (nonatomic, assign) BOOL needStart;

@property (nonatomic, strong) NSError *errorCode;

@end



@implementation DBQRCodeScanner

- (instancetype)initWithPreview:(id<DBQRCodePreview>)preview {
    self = [super init];
    if (self) {
        self.preview = preview;
        self.preview.delegate = self;
        self.errorCode = nil;
        self.session = nil;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [self loadScanner];
    }
    
    return self;
}

- (void)loadScanner {
    if (self.session) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        AVCaptureMetadataOutput *output = [self loadAVCaptureOutput];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupOutput:output];
            if (self.needStart) {
                self.needStart = NO;
                [self startScanning];
            }
        });
    });
}

- (AVCaptureMetadataOutput *)loadAVCaptureOutput {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
        self.errorCode = [NSError errorWithDomain:@"DBQRCode.ErrorCode" code:DBQRErrorCodeAVAuthorizationStatusNotAllow userInfo:nil];
        return nil;
    }

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetHigh];

    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
        NSMutableArray<AVMetadataObjectType> *metadataObjectTypes = [NSMutableArray array];
        NSArray<AVMetadataObjectType> *availableTypes = output.availableMetadataObjectTypes;
        if ([availableTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [metadataObjectTypes addObject:AVMetadataObjectTypeQRCode];
        }
        NSArray<AVMetadataObjectType> *barCodeTypes = [self barCodeTypes];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", availableTypes];
        NSArray<AVMetadataObjectType> *filtered = [barCodeTypes filteredArrayUsingPredicate:predicate];
        if (filtered.count) {
            [metadataObjectTypes addObjectsFromArray:filtered];
        }
        output.metadataObjectTypes = metadataObjectTypes;
    }

    [device lockForConfiguration:nil];
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    }
    [device unlockForConfiguration];
    self.session = session;

    return output;
}

- (void)setupOutput:(AVCaptureMetadataOutput *)output {
    if (output == nil) {
        return;
    }
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    UIView *previewView = self.preview.previewView;

    previewLayer.frame = previewView.layer.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [previewView.layer insertSublayer:previewLayer atIndex:0];
    CGRect rectFrame = self.preview.rectFrame;
    if (!CGRectEqualToRect(rectFrame, CGRectZero)) {
        CGFloat y = rectFrame.origin.y / previewView.bounds.size.height;
        CGFloat x = (previewView.bounds.size.width - rectFrame.origin.x - rectFrame.size.width) / previewView.bounds.size.width;
        CGFloat h = rectFrame.size.height / previewView.bounds.size.height;
        CGFloat w = rectFrame.size.width / previewView.bounds.size.width;
        output.rectOfInterest = CGRectMake(y, x, h, w);
    }

    // 缩放手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchPreview:)];
    [previewView addGestureRecognizer:pinchGesture];
}

#pragma mark - private

- (NSArray<AVMetadataObjectType> *)barCodeTypes {
    return @[AVMetadataObjectTypeCode128Code,
             AVMetadataObjectTypeEAN13Code,
             AVMetadataObjectTypeEAN8Code,
             AVMetadataObjectTypeUPCECode,
             AVMetadataObjectTypeCode39Code,
             AVMetadataObjectTypeCode39Mod43Code,
             AVMetadataObjectTypeCode93Code,
             AVMetadataObjectTypePDF417Code];
}

- (void)startScanning {
    if (!self.session) {
        self.needStart = YES;
        return;
    }
    self.needStart = NO;

    if (self.session && !self.session.isRunning) {
        [self.session startRunning];
        [self.preview startScanning];
    }

    [self.preview startScanning];
    DBQRCodeWeakSelf;
    [self observeLightStatus:^(BOOL dimmed, BOOL torchOn) {
        DBQRCodeStrongSelf;
        if (dimmed || torchOn) {
            [self.preview stopScanning];
            [self.preview showTorchSwitch];
        } else {
            [self.preview hideTorchSwitch];
            [self.preview startScanning];
        }
    }];
}

- (void)stopScanning {
    if (self.session.isRunning) {
        [self.session stopRunning];
        [self.preview stopScanning];
    }
    if (self.torchOn) {
        [DBDeviceHelper switchTorch:NO];
    }
    self.torchOn = NO;
    [self resetZoomFactor];
}

- (void)handleCode:(NSString *)code {
    [self stopScan];
    [self.preview startIndicating];
    if (self.callback) {
        self.callback(code, nil);
    }
    [self.preview stopIndicating];
}

- (void)resetZoomFactor {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    device.videoZoomFactor = 1.0;
    [device unlockForConfiguration];
}

#pragma mark - pinchPreview

- (void)pinchPreview:(UIPinchGestureRecognizer *)gesture {

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    CGFloat minZoomFactor = 1.0;
    CGFloat maxZoomFactor = device.activeFormat.videoMaxZoomFactor;

    if (@available(iOS 11.0, *)) {
        minZoomFactor = device.minAvailableVideoZoomFactor;
        maxZoomFactor = device.maxAvailableVideoZoomFactor;
    }

    static CGFloat lastZoomFactor = 1.0;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastZoomFactor = device.videoZoomFactor;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat zoomFactor = lastZoomFactor * gesture.scale;
        zoomFactor = fmaxf(fminf(zoomFactor, maxZoomFactor), minZoomFactor);
        [device lockForConfiguration:nil];
        device.videoZoomFactor = zoomFactor;
        [device unlockForConfiguration];
    }
}

#pragma mark - 打开/关闭手电筒

- (void)observeLightStatus:(void (^)(BOOL dimmed, BOOL torchOn))lightObserver {
    self.lightObserver = lightObserver;
    AVCaptureVideoDataOutput *lightOutput = [AVCaptureVideoDataOutput new];
    [lightOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    if ([self.session canAddOutput:lightOutput]) {
        [self.session addOutput:lightOutput];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate for light

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDicRef = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CFDictionaryRef exif = CFDictionaryGetValue(metadataDicRef, kCGImagePropertyExifDictionary);
    CGFloat brightness= 0.0;
    if (exif) {
        CFNumberRef bright = CFDictionaryGetValue(exif,kCGImagePropertyExifBrightnessValue);
        brightness = [(__bridge NSNumber *)bright floatValue];
    }
    CFRelease(metadataDicRef);

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL torchOn = device.torchMode == AVCaptureTorchModeOn;
    BOOL dimmed = brightness < 0.0;
    static BOOL lastDimmed = NO;

    if (self.lightObserver) {
        if (!self.lightObserverCalled) {
            self.lightObserverCalled = YES;
            self.lightObserver(dimmed, torchOn);

        } else if (dimmed != lastDimmed) {
             self.lightObserver(dimmed, torchOn);
        }
    }
    lastDimmed = dimmed;
}

#pragma mark - DBQRCodePreviewDelegate

- (void)codePreviewView:(id<DBQRCodePreview>)previewView torchSwitchTapped:(BOOL)onState {
    [DBDeviceHelper switchTorch:onState];
    self.lightObserverCalled = onState;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleCode:metadataObject.stringValue];
        });
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *message = [DBQRCodeManager detectQRCode:image];
        [self handleCode:message];
    }];
}

#pragma mark - public

- (void)scanWithCallback:(DBQRCodeScanCallback)callback {
    if (self.errorCode) {
        callback(nil, self.errorCode);
        return;
    }
    self.callback =  callback;

    self.isScanning = YES;
    [self startScanning];
}

- (void)stopScan {
    self.isScanning = NO;
    [self stopScanning];
}

- (void)scanAlbumWithRooter:(UIViewController *)rooter callback:(DBQRCodeScanCallback)callback {
    self.callback =  callback;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *pickerC = [UIImagePickerController new];
        pickerC.delegate = self;
        pickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [rooter presentViewController:pickerC animated:YES completion:nil];
    } else {
        callback(nil, [NSError errorWithDomain:@"DBQRCode.ErrorCode" code:DBQRErrorCodePHAuthorizationStatusNotAllow userInfo:nil]);
    }
}


- (void)willEnterForeground:(NSNotification *)notification {
    if (self.isScanning) {
        [self startScanning];
    }
}

- (void)didEnterBackground:(NSNotification *)notification {
    if (self.isScanning) {
        [self stopScanning];
    }
}

#pragma mark - internal

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
