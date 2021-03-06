//
//  ScanViewController.m
//  Demo
//
//  Created by bob on 2019/3/31.
//  Copyright © 2019 bob. All rights reserved.
//

#import "ScanViewController.h"
#import <DBQRCode/DBQRCodeManager.h>
#import <DBQRCode/DBQRCodePreviewView.h>
#import <DBQRCode/DBQRCodeScanner.h>
#import <Photos/PHPhotoLibrary.h>

#import <AVFoundation/AVFoundation.h>

@interface ScanViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) DBQRCodeScanner *scanner;
@property (nonatomic, strong) DBQRCodePreviewView *previewView;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRight)];

    DBQRCodePreviewView *preView = [[DBQRCodePreviewView alloc] initWithFrame:self.view.bounds];
    preView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.previewView = preView;
    [self.view addSubview:preView];

    [self requestCameraAccess];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanner stopScan];
}

- (void)requestCameraAccess {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self loadScanView];
            } else {
                [self requestAccessWithTitle:@"扫码二维码需要相机权限，是否重新设置？"];
            }
        });
    }];
}

- (void)loadScanView {
    DBQRCodeScanner *scanner = [[DBQRCodeScanner alloc] initWithPreview:self.previewView];
    [scanner scanWithCallback:^(NSString *code, NSError *error) {
        NSLog(@"%@",code);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.scanner = scanner;
}

#pragma mark - 相册

- (void)clickRight {

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized: //已获取权限
                break;
            default://其他。。。
                [self requestAccessWithTitle:@"需要相册权限，是否重新设置？"];
                return;
        }
    }];

    [self.scanner scanAlbumWithRooter:self callback:^(NSString * _Nullable code, NSError * _Nullable error) {
        NSLog(@"code %@",code);
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
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confimAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

@end
