//
//  DBQRCodeScanViewController.m
//  DBQRCode
//
//  Created by bob on 2019/4/4.
//

#import "DBQRCodeScanViewController.h"
#import "DBQRCodeScanner.h"
#import "DBQRCodePreviewView.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>

@interface DBQRCodeScanViewController ()

@property (nonatomic, strong) DBQRCodeScanner *scanner;
@property (nonatomic, strong) DBQRCodePreviewView *previewView;
@property (nonatomic, copy) DBQRCodeScanCallback callback;

@property (nonatomic, strong) UIImage *lastBackgroundImageForBarMetrics;
@property (nonatomic, strong) UIImage *lastShadowImage;

@end

@implementation DBQRCodeScanViewController

- (instancetype)initWithCallback:(DBQRCodeScanCallback)callback {
    self = [super initWithNibName:nil bundle:[NSBundle bundleForClass:[DBQRCodeScanViewController class]]];
    if (self) {
        self.callback = callback;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册"
                                                                              style:(UIBarButtonItemStylePlain)
                                                                             target:self
                                                                             action:@selector(clickRight)];

    self.navigationItem.title = @"二维码/条码";

    DBQRCodePreviewView *preView = [[DBQRCodePreviewView alloc] initWithFrame:self.view.bounds];
    preView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.previewView = preView;
    [self.view addSubview:preView];

    [self requestCameraAccess];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.lastBackgroundImageForBarMetrics = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    self.lastShadowImage = self.navigationController.navigationBar.shadowImage;

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:self.lastBackgroundImageForBarMetrics forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:self.lastShadowImage];

    [super viewWillDisappear:animated];
    [self.scanner stopScan];
}

- (void)requestCameraAccess {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self loadScanView];
            } else {
                [self requestAccessWithTitle:@"扫面二维码需要相机权限，是否重新设置？"];
            }
        });
    }];
}

- (void)loadScanView {
    DBQRCodeScanner *scanner = [[DBQRCodeScanner alloc] initWithPreview:self.previewView];
    [scanner scanWithCallback:^(NSString *code, NSError *error) {
        if (self.callback) {
            self.callback(code, error);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.scanner = scanner;
}

#pragma mark - button

- (void)clickRight {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                break;
            default:
                [self requestAccessWithTitle:@"需要相册权限，是否重新设置？"];
                return;
        }
    }];

    [self.scanner scanAlbumWithRooter:self callback:^(NSString * _Nullable code, NSError * _Nullable error) {
        if (self.callback) {
            self.callback(code, error);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - setting

- (void)requestAccessWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confimAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

@end

