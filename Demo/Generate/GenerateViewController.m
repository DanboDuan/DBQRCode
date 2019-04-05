//
//  GenerateViewController.m
//  Demo
//
//  Created by bob on 2019/3/31.
//  Copyright © 2019 bob. All rights reserved.
//

#import "GenerateViewController.h"
#import <DBQRCode/DBQRCodeManager.h>

@interface GenerateViewController ()

@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) UITextField *codeInput;

@end

@implementation GenerateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    CGFloat width = self.view.bounds.size.width;
    UITextField *input = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, width - 40, 44)];
    input.borderStyle = UITextBorderStyleRoundedRect;
    input.text = @"https://baidu.com";
    self.codeInput = input;
    [self.view addSubview:input];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 160, width - 40, width - 40)];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(codeImageViewTapped)];
    [imageView addGestureRecognizer:tap];
    self.codeImageView = imageView;
    [self.view addSubview:imageView];

    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(20, width + 140, width - 40, 44)];
    [button1 setTitle:@"生成二维码" forState:(UIControlStateNormal)];
    [button1 addTarget:self action:@selector(generateQRCode) forControlEvents:(UIControlEventTouchUpInside)];
    button1.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button1];

    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(20, width + 200, width - 40, 44)];
    [button2 setTitle:@"生成条形码" forState:(UIControlStateNormal)];
    [button2 addTarget:self action:@selector(generateBarCode) forControlEvents:(UIControlEventTouchUpInside)];
    button2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button2];
}

- (void)generateQRCode {
    NSString *code = self.codeInput.text;
    CGSize size = self.codeImageView.bounds.size;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [DBQRCodeManager generateQRCode:code size:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.codeImageView.image = image;
        });
    });
}

- (void)generateBarCode {
    NSString *code = self.codeInput.text;
    CGSize size = self.codeImageView.bounds.size;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [DBQRCodeManager generateBarCode:code size:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.codeImageView.image = image;
        });
    });
}

- (void)codeImageViewTapped {
    if (!self.codeImageView.image) {
        return;
    }
    NSString *code = self.codeInput.text;
    NSURL *codeURL = [NSURL URLWithString:code];

    if (codeURL && [[UIApplication sharedApplication] canOpenURL:codeURL]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"使用Safari打开链接" message:codeURL.absoluteString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:codeURL options:@{} completionHandler:nil];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:confimAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

@end
