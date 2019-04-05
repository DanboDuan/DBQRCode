//
//  DBQRCodePreviewView.m
//  DBQRCode
//
//  Created by bob on 2019/4/2.
//

#import "DBQRCodePreviewView.h"
#import "DBResources.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface DBQRCodePreviewView ()

@property (nonatomic, strong) UIColor *rectColor;
@property (nonatomic, assign) CGRect rectFrame;

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CABasicAnimation *lineAnimation;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *torchSwithButton;
@property (nonatomic, strong) UIButton *torchSwithLabel;
@property (nonatomic, strong) UILabel *tipsLabel;

@end


@implementation DBQRCodePreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame rectColor:[UIColor colorWithRed:0x1A/255.0 green:0xFA/255.0 blue:0x29/255.0 alpha:1.0]];
}

- (instancetype)initWithFrame:(CGRect)frame rectColor:(UIColor *)rectColor {
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat rectSide = fminf(width, height) * 2 / 3;
    CGRect rectFrame = CGRectMake((width - rectSide) / 2, (height - rectSide) / 2, rectSide, rectSide);

    return [self initWithFrame:frame rectColor:rectColor rectFrame:rectFrame];
}

- (instancetype)initWithFrame:(CGRect)frame rectColor:(UIColor *)rectColor rectFrame:(CGRect)rectFrame {
    self = [super initWithFrame:frame];
    if (self) {
        self.rectFrame = rectFrame;
        self.rectColor = rectColor;

        self.layer.masksToBounds = YES;
        self.clipsToBounds = YES;
        CGFloat rectWidth = rectFrame.size.width;
        CGFloat rectHeight = rectFrame.size.height;


        CGFloat lineWidth = .5;
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(lineWidth,
                                                                             lineWidth,
                                                                             rectWidth - lineWidth,
                                                                             rectHeight - lineWidth)];
        CAShapeLayer *rectLayer = [CAShapeLayer layer];
        rectLayer.fillColor = [UIColor clearColor].CGColor;
        rectLayer.strokeColor = rectColor.CGColor;
        rectLayer.path = rectPath.CGPath;
        rectLayer.lineWidth = lineWidth;
        rectLayer.frame = rectFrame;
        [self.layer addSublayer:rectLayer];

        CGFloat cornerWidth = 2.0;
        CGFloat cornerLength = fminf(rectWidth, rectHeight) / 12;
        UIBezierPath *cornerPath = [UIBezierPath bezierPath];

        // 左上角
        [cornerPath moveToPoint:CGPointMake(cornerWidth / 2, cornerLength)];
        [cornerPath addLineToPoint:CGPointMake(cornerWidth / 2, cornerWidth / 2)];
        [cornerPath addLineToPoint:CGPointMake(cornerLength, cornerWidth / 2)];

        // 右上角
        [cornerPath moveToPoint:CGPointMake(rectWidth - cornerLength, cornerWidth / 2)];
        [cornerPath addLineToPoint:CGPointMake(rectWidth - cornerWidth / 2, cornerWidth / 2)];
        [cornerPath addLineToPoint:CGPointMake(rectWidth - cornerWidth / 2, cornerLength)];

        // 右下角
        [cornerPath moveToPoint:CGPointMake(rectWidth - cornerWidth / 2, rectHeight - cornerLength)];
        [cornerPath addLineToPoint:CGPointMake(rectWidth - cornerWidth / 2, rectHeight - cornerWidth / 2)];
        [cornerPath addLineToPoint:CGPointMake(rectWidth - cornerLength, rectHeight -cornerWidth / 2)];

        // 左下角
        [cornerPath moveToPoint:CGPointMake(cornerLength, rectHeight -cornerWidth / 2)];
        [cornerPath addLineToPoint:CGPointMake(cornerWidth / 2, rectHeight - cornerWidth / 2)];
        [cornerPath addLineToPoint:CGPointMake(cornerWidth / 2, rectHeight - cornerLength)];

        CAShapeLayer *cornerLayer = [CAShapeLayer layer];
        cornerLayer.frame = rectFrame;
        cornerLayer.fillColor = [UIColor clearColor].CGColor;
        cornerLayer.path = cornerPath.CGPath;
        cornerLayer.lineWidth = cornerWidth;
        cornerLayer.strokeColor = rectColor.CGColor;
        [self.layer addSublayer:cornerLayer];

        // 遮罩+镂空
        self.layer.backgroundColor = [UIColor blackColor].CGColor;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
        UIBezierPath *subPath = [[UIBezierPath bezierPathWithRect:rectFrame] bezierPathByReversingPath];
        [maskPath appendPath:subPath];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor colorWithWhite:.0 alpha:.4].CGColor;
        maskLayer.path = maskPath.CGPath;
        [self.layer addSublayer:maskLayer];

        // 扫面线
        CGRect lineFrame = CGRectMake(rectFrame.origin.x + 5.0, rectFrame.origin.y, rectFrame.size.width - 5.0 * 2, 1.5);
        UIBezierPath *linePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(.0, .0, lineFrame.size.width, lineFrame.size.height)];
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.frame = lineFrame;
        lineLayer.path = linePath.CGPath;
        lineLayer.fillColor = rectColor.CGColor;
        lineLayer.shadowColor = rectColor.CGColor;
        lineLayer.shadowRadius = 5.0;
        lineLayer.shadowOffset = CGSizeMake(.0, .0);
        lineLayer.shadowOpacity = 1.0;
        lineLayer.hidden = YES;
        self.lineLayer = lineLayer;
        [self.layer addSublayer:lineLayer];

        CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        lineAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(rectFrame), CGRectGetMinY(rectFrame) + 1.5)];
        lineAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(rectFrame), CGRectGetMaxY(rectFrame) - 1.5)];
        lineAnimation.repeatCount = CGFLOAT_MAX;
        lineAnimation.autoreverses = YES;
        lineAnimation.duration = 2.0;
        self.lineAnimation = lineAnimation;


        UIButton *torchSwithLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        torchSwithLabel.frame = CGRectMake(CGRectGetMinX(rectFrame),
                                            CGRectGetMaxY(rectFrame) - CGRectGetHeight(rectFrame)/3,
                                            CGRectGetWidth(rectFrame),
                                            CGRectGetHeight(rectFrame)/3);
        torchSwithLabel.titleLabel.font = [UIFont systemFontOfSize:12.0];
        torchSwithLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
        [torchSwithLabel setTitle:@"轻触照亮" forState:UIControlStateNormal];
        [torchSwithLabel setTitle:@"轻触关闭" forState:UIControlStateSelected];
        [torchSwithLabel setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [torchSwithLabel setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        torchSwithLabel.titleEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(rectFrame)/6, 0, 0, 0);
        torchSwithLabel.hidden = YES;
        self.torchSwithLabel = torchSwithLabel;
        [self addSubview:torchSwithLabel];

        UIButton *torchSwithButton = [UIButton buttonWithType:UIButtonTypeCustom];
        torchSwithButton.frame = CGRectMake(CGRectGetMinX(rectFrame),
                                            CGRectGetMaxY(rectFrame) - CGRectGetHeight(rectFrame)/3,
                                            CGRectGetWidth(rectFrame),
                                            CGRectGetHeight(rectFrame)/3);
        [torchSwithButton setImage:[DBResources imageNamed:@"icon_torch_off"]
                          forState:UIControlStateNormal];
        [torchSwithButton setImage:[[DBResources imageNamed:@"icon_torch_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                          forState:UIControlStateSelected];
        [torchSwithButton addTarget:self action:@selector(torchSwitchClicked:) forControlEvents:UIControlEventTouchUpInside];
        torchSwithButton.tintColor = rectColor;
        torchSwithButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(rectFrame)/6, 0);
        torchSwithButton.hidden = YES;
        self.torchSwithButton = torchSwithButton;
        [self addSubview:torchSwithButton];

        // 提示语label
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tipsLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.font = [UIFont systemFontOfSize:13.0];
        tipsLabel.text = @"将二维码/条形码放入框内即可自动扫描";
        tipsLabel.numberOfLines = 0;
        [tipsLabel sizeToFit];
        tipsLabel.center = CGPointMake(CGRectGetMidX(rectFrame), CGRectGetMaxY(rectFrame) + CGRectGetMidY(tipsLabel.bounds)+ 12.0);
        [self addSubview:tipsLabel];
        self.tipsLabel = tipsLabel;

        // 等待指示view
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:rectFrame];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicatorView.hidesWhenStopped = YES;
        self.indicatorView = indicatorView;
        [self addSubview:indicatorView];
    }

    return self;
}

#pragma mark - internal

- (void)torchSwitchClicked:(UIButton *)button {
    button.selected = !button.selected;
    self.torchSwithLabel.selected = button.selected;
    if ([self.delegate respondsToSelector:@selector(codePreviewView:torchSwitchTapped:)]) {
        [self.delegate codePreviewView:self torchSwitchTapped:button.selected];
    }
}

#pragma mark - DBQRCodePreview

- (UIView *)previewView {
    return self;
}

- (void)startScanning {
    self.lineLayer.hidden = NO;
    [self.lineLayer addAnimation:self.lineAnimation forKey:@"lineAnimation"];
}

- (void)stopScanning {
    [self.lineLayer removeAnimationForKey:@"lineAnimation"];
    self.lineLayer.hidden = YES;
}

- (void)startIndicating {
    [self.indicatorView startAnimating];
}

- (void)stopIndicating {
    [self.indicatorView stopAnimating];
}

- (void)showTorchSwitch {
    [self stopScanning];
    self.torchSwithButton.hidden = NO;
    self.torchSwithButton.alpha = .0;

    self.torchSwithLabel.hidden = NO;
    self.torchSwithLabel.alpha = .0;

    self.tipsLabel.hidden = YES;
    [UIView animateWithDuration:.25 animations:^{
        self.torchSwithButton.alpha = 1.0;
        self.torchSwithLabel.alpha = 1.0;
    }];
}

- (void)hideTorchSwitch {
    [UIView animateWithDuration:.1 animations:^{
        self.torchSwithButton.alpha = .0;
        self.torchSwithLabel.alpha = .0;
    } completion:^(BOOL finished) {
        self.torchSwithButton.hidden = YES;
        self.torchSwithLabel.hidden = YES;

        self.tipsLabel.hidden = NO;
        [self startScanning];
    }];
}

@end
